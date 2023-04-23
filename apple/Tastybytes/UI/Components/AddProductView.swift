import CachedAsyncImage
import PhotosUI
import SwiftUI

struct AddProductView: View {
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

  private let logger = getLogger(category: "ProductSheet")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var sheetManager: SheetManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var appDataManager: AppDataManager
  @FocusState private var focusedField: Focusable?
  @State private var subcategories: [Subcategory] = []

  let mode: Mode
  let onEdit: (() async -> Void)?
  let onCreate: ((_ product: Product.Joined) async -> Void)?

  init(
    mode: Mode,
    initialBarcode: Barcode? = nil,
    onEdit: (() async -> Void)? = nil,
    onCreate: ((_ product: Product.Joined) -> Void)? = nil
  ) {
    self.mode = mode
    _barcode = State(wrappedValue: initialBarcode)
    self.onEdit = onEdit
    self.onCreate = onCreate
  }

  @State private var category: Category.JoinedSubcategoriesServingStyles? {
    didSet {
      withAnimation {
        subcategories.removeAll()
      }
    }
  }

  @State private var brandOwner: Company? {
    didSet {
      brand = nil
    }
  }

  @State private var brand: Brand.JoinedSubBrands? {
    didSet {
      hasSubBrand = false
      subBrand = nil
    }
  }

  @State private var subBrand: SubBrandProtocol?
  @State private var name: String = ""
  @State private var description: String = ""
  @State private var hasSubBrand = false {
    didSet {
      if oldValue == true {
        subBrand = nil
      }
    }
  }

  @State private var barcode: Barcode?
  @State private var isLoading = false

  @State private var selectedLogo: PhotosPickerItem? {
    didSet {
      Task { await uploadLogo() }
    }
  }

  @State private var logoFile: String?
  @State private var productId: Int?

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
    .task {
      await loadMissingData(categories: appDataManager.categories)
    }
  }

  private var action: some View {
    ProgressButton(mode.doneLabel, action: {
      switch mode {
      case .editSuggestion:
        await createProductEditSuggestion()
      case .edit:
        await editProduct()
      case .new:
        await createProduct(onSuccess: { product in
          feedbackManager.trigger(.notification(.success))
          router.navigate(screen: .product(product), resetStack: true)
        })
      case .addToBrand:
        await createProduct(onSuccess: { product in
          feedbackManager.trigger(.notification(.success))
          if let onCreate {
            await onCreate(product)
          }
        })
      }
    })
    .fontWeight(.medium)
    .disabled(isLoading || !isValid())
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
  }

  private var categorySection: some View {
    Section {
      Picker("Category", selection: $category) {
        Text("None").tag(Category.JoinedSubcategoriesServingStyles?(nil))
          .fontWeight(.medium)
        ForEach(appDataManager.categories) { category in
          Text(category.name)
            .fontWeight(.medium)
            .tag(Optional(category))
        }
      }

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
              .fontWeight(.medium)
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
        .fontWeight(.medium)
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
        setBrandOwner(company)
      }))
      .fontWeight(.medium)

      if let brandOwner {
        RouterLink(
          brand?.name ?? "Brand",
          sheet: .brand(brandOwner: brandOwner, mode: .select, onSelect: { brand, createdNew in
            if createdNew {
              feedbackManager.toggle(.success(Toast.createdBrand.text))
            }
            setBrand(brand: brand)
          })
        )
        .fontWeight(.medium)
      }

      if brand != nil {
        Toggle("Has sub-brand?", isOn: $hasSubBrand)
      }

      if hasSubBrand, let brand {
        RouterLink(
          subBrand?.name ?? "Sub-brand",
          sheet: .subBrand(brandWithSubBrands: brand, onSelect: { subBrand, createdNew in
            if createdNew {
              feedbackManager.toggle(.success(Toast.createdSubBrand.text))
            }
            self.subBrand = subBrand
          })
        )
        .fontWeight(.medium)
      }

    } header: {
      Text("Brand")
        .fontWeight(.medium)
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
        .fontWeight(.medium)
        .focused($focusedField, equals: .name)

      TextField("Description (optional)", text: $description)
        .fontWeight(.medium)
        .focused($focusedField, equals: .description)

      if mode == .new {
        RouterLink(barcode == nil ? "Add Barcode" : "Barcode Added!", sheet: .barcodeScanner(onComplete: { barcode in
          self.barcode = barcode
        }))
        .fontWeight(.medium)
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

  func getSubcategoriesForCategory() -> [Subcategory]? {
    category?.subcategories
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
