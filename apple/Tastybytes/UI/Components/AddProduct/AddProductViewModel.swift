import PhotosUI
import SwiftUI

extension AddProductView {
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
  }

  enum Focusable {
    case name, description
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

  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ProductSheet")
    let client: Client
    @Published var mode: Mode
    @Published var category: Category.JoinedSubcategoriesServingStyles? {
      didSet {
        withAnimation {
          subcategories.removeAll()
        }
      }
    }

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
    @Published var isLoading = false

    @Published var selectedLogo: PhotosPickerItem? {
      didSet {
        Task { await uploadLogo() }
      }
    }

    @Published var logoFile: String?
    var productId: Int?

    init(_ client: Client, mode: Mode, barcode: Barcode?) {
      self.client = client
      self.mode = mode
      self.barcode = barcode
    }

    func getSubcategoriesForCategory() -> [Subcategory]? {
      category?.subcategories
    }

    func createSubcategory(newSubcategoryName: String, onCreate: @escaping () async -> Void) async {
      guard let categoryWithSubcategories = category else { return }
      isLoading = true
      switch await client.subcategory
        .insert(newSubcategory: Subcategory
          .NewRequest(name: newSubcategoryName, category: categoryWithSubcategories))
      {
      case .success:
        await onCreate()
      case let .failure(error):
        logger.error("failed to create subcategory '\(newSubcategoryName)': \(error.localizedDescription)")
      }
      isLoading = false
    }

    func setBrand(brand: Brand.JoinedSubBrands) {
      self.brand = brand
      subBrand = brand.subBrands.first(where: { $0.name == nil })
    }

    func setBrandOwner(_ brandOwner: Company) {
      self.brandOwner = brandOwner
    }

    func isValid() -> Bool {
      category != nil && brandOwner != nil && brand != nil && name.isValidLength(.normal)
    }

    func getToastText(_ toast: Toast) -> String {
      toast.text
    }

    func loadMissingData(categories: [Category.JoinedSubcategoriesServingStyles]) async {
      switch mode {
      case let .edit(initialProduct), let .editSuggestion(initialProduct):
        await loadValuesFromExistingProduct(initialProduct, categories: categories)
      case let .addToBrand(brand):
        loadFromBrand(brand, categories: categories)
      case .new:
        category = categories.first(where: { $0.name == "beverage" })
      }
    }

    func loadFromBrand(_ brand: Brand.JoinedSubBrandsProductsCompany, categories: [Category.JoinedSubcategoriesServingStyles]) {
      category = categories.first(where: { $0.name == "beverage" })
      subcategories = []
      brandOwner = brand.brandOwner
      self.brand = Brand.JoinedSubBrands(
        id: brand.id,
        name: brand.name,
        logoFile: brand.logoFile,
        isVerified: brand.isVerified,
        subBrands: brand.subBrands
          .map { subBrand in SubBrand(id: subBrand.id, name: subBrand.name, isVerified: subBrand.isVerified) }
      )
      subBrand = nil
    }

    func loadValuesFromExistingProduct(
      _ initialProduct: Product.Joined,
      categories: [Category.JoinedSubcategoriesServingStyles]
    ) async {
      switch await client.brand
        .getByBrandOwnerId(brandOwnerId: initialProduct.subBrand.brand.brandOwner.id)
      {
      case let .success(brandsWithSubBrands):
        productId = initialProduct.id
        category = categories.first(where: { $0.id == initialProduct.category.id })
        subcategories = initialProduct.subcategories.map { $0.getSubcategory() }
        brandOwner = initialProduct.subBrand.brand.brandOwner
        brand = Brand.JoinedSubBrands(
          id: initialProduct.subBrand.brand.id,
          name: initialProduct.subBrand.brand.name,
          logoFile: initialProduct.subBrand.brand.logoFile,
          isVerified: initialProduct.subBrand.brand.isVerified,
          subBrands: brandsWithSubBrands
            .first(where: { $0.id == initialProduct.subBrand.brand.id })?.subBrands ?? []
        )
        subBrand = initialProduct.subBrand
        name = initialProduct.name
        description = initialProduct.description.orEmpty
        hasSubBrand = initialProduct.subBrand.name != nil
        logoFile = initialProduct.logoFile
      case let .failure(error):
        logger.error("failed to load brand owner for product '\(initialProduct.id)': \(error.localizedDescription)")
      }
    }

    func createProduct(onSuccess: @escaping (_ product: Product.Joined) async -> Void) async {
      guard let category, let brandId = brand?.id else { return }
      let newProductParams = Product.NewRequest(
        name: name,
        description: description,
        categoryId: category.id,
        brandId: brandId,
        subBrandId: subBrand?.id,
        subCategoryIds: subcategories.map(\.id),
        barcode: barcode
      )
      switch await client.product.create(newProductParams: newProductParams) {
      case let .success(newProduct):
        await onSuccess(newProduct)
      case let .failure(error):
        logger.error("failed to create new product: \(error.localizedDescription)")
      }
    }

    func createProductEditSuggestion(onSuccess: @escaping () -> Void) async {
      guard let subBrand, let category, let productId else { return }
      let productEditSuggestionParams = Product.EditRequest(
        productId: productId,
        name: name,
        description: description,
        categoryId: category.id,
        subBrandId: subBrand.id,
        subcategories: subcategories
      )

      switch await client.product
        .createUpdateSuggestion(productEditSuggestionParams: productEditSuggestionParams)
      {
      case .success:
        onSuccess()
      case let .failure(error):
        logger.error("failed to create product edit suggestion for '\(productId)': \(error.localizedDescription)")
      }
    }

    func uploadLogo() async {
      guard let productId else { return }
      guard let data = await selectedLogo?.getJPEG() else { return }
      switch await client.product.uploadLogo(productId: productId, data: data) {
      case let .success(filename):
        logoFile = filename
      case let .failure(error):
        logger.error("uplodaing company logo failed: \(error.localizedDescription)")
      }
    }

    func editProduct(onSuccess: @escaping () async -> Void) async {
      guard let category, let brand, let productId else { return }
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

      switch await client.product.editProduct(productEditParams: productEditParams) {
      case .success:
        await onSuccess()
      case let .failure(error):
        logger.error("failed to edit product '\(productId)': \(error.localizedDescription)")
      }
    }
  }
}
