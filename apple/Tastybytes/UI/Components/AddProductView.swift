import CachedAsyncImage
import PhotosUI
import SwiftUI

struct ProductMutationView: View {
  private let logger = getLogger(category: "ProductMutationView")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var appDataManager: AppDataManager
  @Environment(\.dismiss) private var dismiss
  @State private var subcategories: [Subcategory] = []
  @State private var category: Category.JoinedSubcategoriesServingStyles?
  @State private var brandOwner: Company?
  @State private var brand: Brand.JoinedSubBrands?
  @State private var subBrand: SubBrandProtocol?
  @State private var name: String = ""
  @State private var description: String = ""
  @State private var hasSubBrand = false
  @State private var logoFile: String?
  @State private var productId: Int?
  @State private var initialDataLoaded = false

  let mode: AddProductView.Mode
  let onEdit: (() async -> Void)?
  let onCreate: ((_ product: Product.Joined) -> Void)?
  let initialBarcode: Barcode?
  let isSheet: Bool

  init(
    mode: AddProductView.Mode,
    isSheet: Bool = true,
    initialBarcode: Barcode? = nil,
    onEdit: (() async -> Void)? = nil,
    onCreate: ((_ product: Product.Joined) -> Void)? = nil
  ) {
    self.mode = mode
    self.isSheet = isSheet
    self.initialBarcode = initialBarcode
    self.onEdit = onEdit
    self.onCreate = onCreate
  }

  var navigationTitle: String {
    switch mode {
    case .addToBrand, .addToSubBrand, .new:
      return "Add Product"
    case .edit:
      return "Edit Product"
    case .editSuggestion:
      return "Edit Suggestion"
    }
  }

  var body: some View {
    VStack {
      if initialDataLoaded {
        AddProductView(mode: mode, productId: productId, category: category,
                       brandOwner: brandOwner,
                       brand: brand,
                       hasSubBrand: hasSubBrand,
                       subBrand: subBrand,
                       name: name,
                       description: description,
                       subcategories: subcategories,
                       initialBarcode: initialBarcode, onEdit: onEdit, onCreate: onCreate)
      }
    }
    .navigationTitle(navigationTitle)
    .if(isSheet, transform: { view in
      view.toolbar {
        toolbarContent
      }
    })
    .task {
      await loadMissingData(categories: appDataManager.categories)
    }
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarLeading) {
      Button("Cancel", role: .cancel, action: { dismiss() }).bold()
    }
  }

  func loadMissingData(categories: [Category.JoinedSubcategoriesServingStyles]) async {
    switch mode {
    case let .edit(initialProduct), let .editSuggestion(initialProduct):
      await loadValuesFromExistingProduct(initialProduct, categories: categories)
    case let .addToBrand(brand):
      loadFromBrand(brand, categories: categories)
    case let .addToSubBrand(brand, subBrand):
      loadFromSubBrand(brand: brand, subBrand: subBrand, categories: categories)
    case .new:
      category = categories.first(where: { $0.name == "beverage" })
    }
    initialDataLoaded = true
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

  func loadFromSubBrand(
    brand: Brand.JoinedSubBrandsProductsCompany,
    subBrand: SubBrand.JoinedProduct,
    categories: [Category.JoinedSubcategoriesServingStyles]
  ) {
    category = categories.first(where: { $0.name == "beverage" })
    subcategories = []
    brandOwner = brand.brandOwner
    let subBrandsFromBrand = brand.subBrands
      .map { subBrand in SubBrand(id: subBrand.id, name: subBrand.name, isVerified: subBrand.isVerified) }
    self.brand = Brand.JoinedSubBrands(
      id: brand.id,
      name: brand.name,
      logoFile: brand.logoFile,
      isVerified: brand.isVerified,
      subBrands: subBrandsFromBrand
    )
    hasSubBrand = true
    self.subBrand = subBrandsFromBrand.first(where: { $0.id == subBrand.id })
  }

  func loadValuesFromExistingProduct(
    _ initialProduct: Product.Joined,
    categories: [Category.JoinedSubcategoriesServingStyles]
  ) async {
    switch await repository.brand
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
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to load brand owner for product '\(initialProduct.id)': \(error.localizedDescription)")
    }
  }
}

struct AddProductView: View {
  private let logger = getLogger(category: "ProductSheet")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var sheetManager: SheetManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var appDataManager: AppDataManager
  @Environment(\.dismiss) private var dismiss
  @FocusState private var focusedField: Focusable?
  @State private var subcategories: [Subcategory]
  @State private var category: Category.JoinedSubcategoriesServingStyles?
  @State private var brandOwner: Company? {
    didSet {
      brand = nil
      subBrand = nil
      hasSubBrand = false
    }
  }

  @State private var brand: Brand.JoinedSubBrands?

  @State private var subBrand: SubBrandProtocol?
  @State private var name: String
  @State private var description: String
  @State private var hasSubBrand: Bool {
    didSet {
      if oldValue == true {
        subBrand = nil
      }
    }
  }

  @State private var barcode: Barcode?
  @State private var selectedLogo: PhotosPickerItem? {
    didSet {
      Task { await uploadLogo() }
    }
  }

  @State private var logoFile: String?
  @State private var productId: Int?

  let mode: Mode
  let onEdit: (() async -> Void)?
  let onCreate: ((_ product: Product.Joined) async -> Void)?

  init(
    mode: Mode,
    productId: Int?,
    category: Category.JoinedSubcategoriesServingStyles?,
    brandOwner: Company?,
    brand: Brand.JoinedSubBrands?,
    hasSubBrand: Bool?,
    subBrand: SubBrandProtocol?,
    name: String = "",
    description: String = "",
    subcategories: [Subcategory] = [],
    initialBarcode: Barcode? = nil,
    onEdit: (() async -> Void)? = nil,
    onCreate: ((_ product: Product.Joined) -> Void)? = nil
  ) {
    self.mode = mode
    _barcode = State(wrappedValue: initialBarcode)
    self.onEdit = onEdit
    self.onCreate = onCreate
    _productId = State(initialValue: productId)
    _category = State(initialValue: category)
    _subcategories = State(initialValue: subcategories)
    _brandOwner = State(initialValue: brandOwner)
    _brand = State(initialValue: brand)
    _hasSubBrand = State(initialValue: hasSubBrand ?? false)
    _subBrand = State(initialValue: subBrand)
    _name = State(initialValue: name)
    _description = State(initialValue: description)
  }

  var body: some View {
    Form {
      if profileManager.hasPermission(.canAddProductLogo) {
        logoSection
      }
      categorySection
      brandSection
      productSection
      action
    }
    .onChange(of: subcategories, perform: { newValue in
      subcategories = newValue
    })
  }

  private var action: some View {
    ProgressButton(mode.doneLabel, action: {
      await primaryAction()
    })
    .fontWeight(.medium)
    .disabled(!isValid())
  }

  private var logoSection: some View {
    Section {
      PhotosPicker(
        selection: $selectedLogo,
        matching: .images,
        photoLibrary: .shared()
      ) {
        if let logoFile, let logoUrl = URL(
          bucketId: Product.getQuery(.logoBucket),
          fileName: logoFile
        ) {
          CachedAsyncImage(url: logoUrl, urlCache: .imageCache) { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: 52, height: 52)
              .accessibility(hidden: true)
          } placeholder: {
            Image(systemName: "photo")
              .accessibility(hidden: true)
          }
        } else {
          Image(systemName: "photo")
            .accessibility(hidden: true)
        }
      }
    }
    .listRowSeparator(.hidden)
    .listRowBackground(Color.clear)
    .onChange(of: category) { _ in
      subcategories = []
    }
    .onChange(of: brand) { _ in
      hasSubBrand = false
      if let brand {
        subBrand = brand.subBrands.first(where: { $0.name == nil })
      }
    }
  }

  private var categorySection: some View {
    Section {
      RouterLink(
        category?.name ?? "Pick a category",
        sheet: .categoryPickerSheet(category: $category)
      )

      Button(action: {
        if let category {
          sheetManager.navigate(sheet: .subcategory(
            subcategories: $subcategories,
            category: category
          ))
        }
      }, label: {
        HStack {
          if subcategories.isEmpty {
            Text("Subcategories")
          } else {
            HStack(spacing: 4) {
              ForEach(subcategories) { subcategory in
                SubcategoryLabelView(subcategory: subcategory)
              }
            }
          }
        }
      }).disabled(category == nil)
    }
    header: {
      Text("Category")
        .accessibilityAddTraits(.isButton)
        .onTapGesture {
          focusedField = nil
        }
    }
    .headerProminence(.increased)
  }

  private var brandSection: some View {
    Section {
      RouterLink(brandOwner?.name ?? "Company", sheet: .companySearch(onSelect: { company in
        brandOwner = company
      }))

      if let brandOwner {
        RouterLink(
          brand?.name ?? "Brand",
          sheet: .brand(brandOwner: brandOwner, brand: $brand, mode: .select)
        )
      }

      if brand != nil {
        Toggle("Has sub-brand?", isOn: .init(get: {
          hasSubBrand
        }, set: { newValue in
          hasSubBrand = newValue
          if newValue == false {
            subBrand = nil
          }
        }))
      }

      if hasSubBrand, let brand {
        RouterLink(
          subBrand?.name ?? "Sub-brand",
          sheet: .subBrand(brandWithSubBrands: brand, subBrand: $subBrand)
        )
      }

    } header: {
      Text("Brand")
        .accessibilityAddTraits(.isButton)
        .onTapGesture {
          focusedField = nil
        }
    }
    .headerProminence(.increased)
  }

  private var productSection: some View {
    Section {
      TextField("Name", text: $name)
        .focused($focusedField, equals: .name)

      TextField("Description (optional)", text: $description)
        .focused($focusedField, equals: .description)

      if mode == .new {
        RouterLink(barcode == nil ? "Add Barcode" : "Barcode Added!", sheet: .barcodeScanner(onComplete: { barcode in
          self.barcode = barcode
        }))
      }
    } header: {
      Text("Product")
        .accessibilityAddTraits(.isButton)
        .onTapGesture {
          focusedField = nil
        }
    }
    .headerProminence(.increased)
  }

  func isValid() -> Bool {
    category != nil && brandOwner != nil && brand != nil && name.isValidLength(.normal)
  }

  func primaryAction() async {
    switch mode {
    case .editSuggestion:
      await createProductEditSuggestion()
    case .edit:
      await editProduct()
      if let onEdit {
        await onEdit()
      }
    case .new, .addToBrand, .addToSubBrand:
      await createProduct(onSuccess: { product in
        if let onCreate {
          await onCreate(product)
        }
      })
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
    switch await repository.product.create(newProductParams: newProductParams) {
    case let .success(newProduct):
      feedbackManager.trigger(.notification(.success))
      router.navigate(screen: .product(newProduct))
      dismiss()
      await onSuccess(newProduct)
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to create new product: \(error.localizedDescription)")
    }
  }

  func createProductEditSuggestion() async {
    guard let subBrand, let category, let productId else { return }
    let productEditSuggestionParams = Product.EditRequest(
      productId: productId,
      name: name,
      description: description,
      categoryId: category.id,
      subBrandId: subBrand.id,
      subcategories: subcategories
    )

    switch await repository.product
      .createUpdateSuggestion(productEditSuggestionParams: productEditSuggestionParams)
    {
    case .success:
      dismiss()
      feedbackManager.toggle(.success("Edit suggestion sent!"))
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to create product edit suggestion for '\(productId)': \(error.localizedDescription)")
    }
  }

  func uploadLogo() async {
    guard let productId else { return }
    guard let data = await selectedLogo?.getJPEG() else { return }
    switch await repository.product.uploadLogo(productId: productId, data: data) {
    case let .success(filename):
      logoFile = filename
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("uplodaing company logo failed: \(error.localizedDescription)")
    }
  }

  func editProduct() async {
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

    switch await repository.product.editProduct(productEditParams: productEditParams) {
    case .success:
      feedbackManager.trigger(.notification(.success))
      dismiss()
      if let onEdit {
        await onEdit()
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to edit product '\(productId)': \(error.localizedDescription)")
    }
  }
}

extension AddProductView {
  enum Mode: Equatable {
    case new, edit(Product.Joined), editSuggestion(Product.Joined), addToBrand(Brand.JoinedSubBrandsProductsCompany),
         addToSubBrand(Brand.JoinedSubBrandsProductsCompany, SubBrand.JoinedProduct)

    var doneLabel: String {
      switch self {
      case .edit:
        return "Edit"
      case .editSuggestion:
        return "Submit"
      case .new, .addToBrand, .addToSubBrand:
        return "Create"
      }
    }
  }

  enum Focusable {
    case name, description
  }
}
