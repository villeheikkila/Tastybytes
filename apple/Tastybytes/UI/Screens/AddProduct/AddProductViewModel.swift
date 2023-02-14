import SwiftUI

extension ProductSheetView {
  enum Mode: Equatable {
    case new, edit(Product.Joined), editSuggestion(Product.Joined), addToBrand(Brand.JoinedSubBrandsProductsCompany)

    var doneLabel: String {
      switch self {
      case .edit:
        return "Edit"
      case .editSuggestion:
        return "Send Edit suggestion"
      case .new, .addToBrand:
        return "Create"
      }
    }

    var navigationTitle: String {
      switch self {
      case .edit:
        return "Edit Product"
      case .editSuggestion:
        return "Edit Suggestion"
      case .new, .addToBrand:
        return "Add Product"
      }
    }
  }

  enum Focusable {
    case name, description
  }

  enum Sheet: Identifiable {
    var id: Self { self }
    case subcategories, brandOwner, brand, subBrand, barcode
  }

  enum Toast: Identifiable {
    var id: Self { self }
    case createdCompany
    case createdBrand
    case createdSubBrand

    var text: String {
      switch self {
      case .createdCompany:
        return "New Company Created!"
      case .createdBrand:
        return "New Brand Created!"
      case .createdSubBrand:
        return "New Sub-brand Created!"
      }
    }
  }

  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ProductSheetView")
    let client: Client
    @Published var categories = [Category.JoinedSubcategories]()
    @Published var activeSheet: Sheet?
    @Published var mode: Mode
    @Published var categoryName: Category.Name = .beverage {
      // TODO: Investigate if this can be avoided by passing ServingStyle directly to the picker
      didSet {
        category = categories.first(where: { $0.name == categoryName })
      }
    }

    @Published var category: Category.JoinedSubcategories?
    @Published var subcategories: [Subcategory] = []
    @Published var brandOwner: Company? {
      didSet {
        brand = nil
      }
    }

    @Published var brand: Brand.JoinedSubBrands? {
      didSet {
        hasSubBrand = false
        subBrand = nil
      }
    }

    @Published var subBrand: SubBrandProtocol?
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var hasSubBrand = false {
      didSet {
        if oldValue == true {
          subBrand = nil
        }
      }
    }

    @Published var barcode: Barcode?

    var productId: Int?

    init(_ client: Client, mode: Mode, barcode: Barcode?) {
      self.client = client
      self.mode = mode
      self.barcode = barcode
    }

    func getSubcategoriesForCategory() -> [Subcategory]? {
      category?.subcategories
    }

    func createSubcategory(newSubcategoryName: String) {
      if let categoryWithSubcategories = category {
        Task {
          switch await client.subcategory
            .insert(newSubcategory: Subcategory
              .NewRequest(name: newSubcategoryName, category: categoryWithSubcategories))
          {
          case .success:
            self.loadCategories(categoryWithSubcategories.name)
          case let .failure(error):
            logger.error("failed to create subcategory '\(newSubcategoryName)': \(error.localizedDescription)")
          }
        }
      }
    }

    func setBrand(brand: Brand.JoinedSubBrands) {
      self.brand = brand
      subBrand = brand.subBrands.first(where: { $0.name == nil })
      activeSheet = nil
    }

    func setActiveSheet(_ sheet: Sheet) {
      activeSheet = sheet
    }

    func setBrandOwner(_ brandOwner: Company) {
      self.brandOwner = brandOwner
    }

    func dismissSheet() {
      activeSheet = nil
    }

    func isValid() -> Bool {
      brandOwner != nil && brand != nil && validateStringLength(str: name, type: .normal)
    }

    func getToastText(_ toast: Toast) -> String {
      toast.text
    }

    func loadMissingData() {
      switch mode {
      case let .edit(initialProduct), let .editSuggestion(initialProduct):
        loadValuesFromExistingProduct(initialProduct)
      case let .addToBrand(brand):
        loadFromBrand(brand)
      default:
        loadCategories()
      }
    }

    func loadFromBrand(_ brand: Brand.JoinedSubBrandsProductsCompany) {
      Task {
        switch await client.category.getAllWithSubcategories() {
        case let .success(categories):
          self.categories = categories
          self.category = categories.first(where: { $0.name == .beverage })
          self.categoryName = .beverage
          self.subcategories = []
          self.brandOwner = brand.brandOwner
          self.brand = Brand.JoinedSubBrands(
            id: brand.id,
            name: brand.name,
            isVerified: brand.isVerified,
            subBrands: brand.subBrands
              .map { subBrand in SubBrand(id: subBrand.id, name: subBrand.name, isVerified: subBrand.isVerified) }
          )
          self.subBrand = nil
        case let .failure(error):
          logger.error("failed to load categories with subcategories: \(error.localizedDescription)")
        }
      }
    }

    func loadValuesFromExistingProduct(_ initialProduct: Product.Joined) {
      Task {
        async let subcategoriesPromise = client.category.getAllWithSubcategories()
        async let brandOwnerPromise = client.brand
          .getByBrandOwnerId(brandOwnerId: initialProduct.subBrand.brand.brandOwner.id)

        let subcategories = await subcategoriesPromise
        let brandOwner = await brandOwnerPromise

        switch subcategories {
        case let .success(categories):
          switch brandOwner {
          case let .success(brandsWithSubBrands):
            self.productId = initialProduct.id
            self.categories = categories
            self.category = categories.first(where: { $0.id == initialProduct.category.id })
            self.categoryName = category?.name ?? .beverage
            self.subcategories = initialProduct.subcategories.map { $0.getSubcategory() }
            self.brandOwner = initialProduct.subBrand.brand.brandOwner
            self.brand = Brand.JoinedSubBrands(
              id: initialProduct.subBrand.brand.id,
              name: initialProduct.subBrand.brand.name,
              isVerified: initialProduct.subBrand.brand.isVerified,
              subBrands: brandsWithSubBrands
                .first(where: { $0.id == initialProduct.subBrand.brand.id })?.subBrands ?? []
            )
            self.subBrand = initialProduct.subBrand
            self.name = initialProduct.name
            self.description = initialProduct.description.orEmpty
            self.hasSubBrand = initialProduct.subBrand.name != nil
          case let .failure(error):
            logger
              .error("failed to load brand owner for product '\(initialProduct.id)': \(error.localizedDescription)")
          }
        case let .failure(error):
          logger.error("failed to load categories with subcategories: \(error.localizedDescription)")
        }
      }
    }

    func loadCategories(_ initialCategory: Category.Name = Category.Name.beverage) {
      Task {
        switch await client.category.getAllWithSubcategories() {
        case let .success(categories):
          self.categories = categories
          self.category = categories.first(where: { $0.name == initialCategory })
        case let .failure(error):
          logger
            .error(
              """
              failed to load category with subcategories for '\(initialCategory.rawValue)': \(error
                .localizedDescription)
              """
            )
        }
      }
    }

    func createProduct(onCreation: @escaping (_ product: Product.Joined) -> Void) {
      if let category, let brandId = brand?.id {
        let newProductParams = Product.NewRequest(
          name: name,
          description: description,
          categoryId: category.id,
          brandId: brandId,
          subBrandId: subBrand?.id,
          subCategoryIds: subcategories.map(\.id),
          barcode: barcode
        )
        Task {
          switch await client.product.create(newProductParams: newProductParams) {
          case let .success(newProduct):
            onCreation(newProduct)
          case let .failure(error):
            logger.error("failed to create new product: \(error.localizedDescription)")
          }
        }
      }
    }

    func createProductEditSuggestion(onComplete: @escaping () -> Void) {
      if let subBrand, let category, let productId {
        let productEditSuggestionParams = Product.EditRequest(
          productId: productId,
          name: name,
          description: description,
          categoryId: category.id,
          subBrandId: subBrand.id,
          subcategories: subcategories
        )

        Task {
          switch await client.product
            .createUpdateSuggestion(productEditSuggestionParams: productEditSuggestionParams)
          {
          case .success:
            onComplete()
          case let .failure(error):
            logger
              .error(
                "failed to create product edit suggestion for '\(productId)': \(error.localizedDescription)"
              )
          }
          onComplete()
        }
      }
    }

    func editProduct(onComplete: @escaping () -> Void) {
      if let category, let brand, let productId {
        let subBrandWithNil = subBrand == nil ? brand.subBrands.first(where: { $0.name == nil }) : subBrand
        guard let subBrandWithNil else { return }
        let productEditParams = Product.EditRequest(
          productId: productId,
          name: name,
          description: description,
          categoryId: category.id,
          subBrandId: subBrandWithNil.id,
          subcategories: subcategories
        )

        Task {
          switch await client.product.editProduct(productEditParams: productEditParams) {
          case .success:
            onComplete()
          case let .failure(error):
            logger.error("failed to edit product '\(productId)': \(error.localizedDescription)")
          }
        }
      }
    }
  }
}
