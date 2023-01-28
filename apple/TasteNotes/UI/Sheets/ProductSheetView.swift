import SwiftUI

struct ProductSheetView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var toastManager: ToastManager
  @StateObject var viewModel = ViewModel()
  @State var mode = Mode.new
  @FocusState private var focusedField: Focusable?

  let initialProduct: Product.Joined?
  let initialBarcode: Barcode?
  let onEdit: (() -> Void)?

  init(
    mode: Mode,
    initialProduct: Product.Joined? = nil,
    initialBarcode: Barcode? = nil,
    onEdit: (() -> Void)? = nil
  ) {
    self.mode = mode
    self.initialProduct = initialProduct
    self.initialBarcode = initialBarcode
    self.onEdit = onEdit
  }

  var body: some View {
    List {
      categorySection
      brandSection
      productSection

      Button(doneLabel, action: {
        switch mode {
        case .editSuggestion:
          if let initialProduct {
            viewModel.createProductEditSuggestion(product: initialProduct, onComplete: {
              toastManager.toggle(.success("Edit suggestion sent!"))
            })
          }
        case .edit:
          if let initialProduct {
            viewModel.editProduct(product: initialProduct, onComplete: {
              if let onEdit {
                onEdit()
              }
            })
          }
        case .new:
          viewModel.createProduct(onCreation: {
            product in router.navigate(to: .product(product), resetStack: true)
          })
        }
      })
      .disabled(!viewModel.isValid())
    }
    .navigationTitle(navigationTitle)
    .sheet(item: $viewModel.activeSheet) { sheet in
      NavigationStack {
        switch sheet {
        case .subcategories:
          if let subcategoriesForCategory = viewModel.category?.subcategories {
            SubcategorySheetView(
              subcategories: $viewModel.subcategories,
              availableSubcategories: subcategoriesForCategory,
              onCreate: {
                newSubcategoryName in viewModel.createSubcategory(newSubcategoryName: newSubcategoryName)
              }
            )
          }
        case .brandOwner:
          CompanySheetView(onSelect: { company, createdNew in
            viewModel.setBrandOwner(company)
            if createdNew {
              toastManager.toggle(.success(viewModel.getToastText(.createdCompany)))
            }
            viewModel.dismissSheet()
          })
        case .brand:
          if let brandOwner = viewModel.brandOwner {
            BrandSheetView(brandOwner: brandOwner, onSelect: { brand, createdNew in
              if createdNew {
                toastManager.toggle(.success(viewModel.getToastText(.createdSubBrand)))
              }
              viewModel.setBrand(brand: brand)
            })
          }

        case .subBrand:
          if let brand = viewModel.brand {
            SubBrandSheetView(brandWithSubBrands: brand, onSelect: { subBrand, createdNew in
              if createdNew {
                toastManager.toggle(.success(viewModel.getToastText(.createdSubBrand)))
              }
              viewModel.subBrand = subBrand
              viewModel.dismissSheet()

            })
          }
        case .barcode:
          BarcodeScannerSheetView(onComplete: {
            barcode in viewModel.barcode = barcode
          })
        }
      }.if(sheet == .barcode, transform: { view in view.presentationDetents([.medium]) })
    }
    .task {
      if let initialProduct {
        viewModel.loadInitialProduct(initialProduct)
      } else {
        viewModel.loadCategories()
      }
      viewModel.loadInitialBarcode(initialBarcode)
    }
  }

  private var doneLabel: String {
    switch mode {
    case .edit:
      return "Edit"
    case .editSuggestion:
      return "Send Edit suggestion"
    case .new:
      return "Create"
    }
  }

  private var navigationTitle: String {
    switch mode {
    case .edit:
      return "Edit Product"
    case .editSuggestion:
      return "Edit Suggestion"
    case .new:
      return "Add Product"
    }
  }

  private var categorySection: some View {
    Section {
      if viewModel.categories.count > 0 {
        Picker("Category", selection: $viewModel.categoryName) {
          ForEach(viewModel.categories.map(\.name)) { category in
            Text(category.label).tag(category)
          }
        }
        .onChange(of: viewModel.category) { _ in
          viewModel.subcategories.removeAll()
        }
      }

      Button(action: {
        viewModel.setActiveSheet(.subcategories)
      }) {
        HStack {
          if viewModel.subcategories.count == 0 {
            Text("Subcategories")
          } else {
            HStack { ForEach(viewModel.subcategories) { subcategory in
              ChipView(title: subcategory.name)
            }}
          }
        }
      }
    }
    header: {
      Text("Category")
        .onTapGesture {
          self.focusedField = nil
        }
    }
    .headerProminence(.increased)
  }

  private var brandSection: some View {
    Section {
      Button(action: {
        viewModel.setActiveSheet(.brandOwner)
      }) {
        Text(viewModel.brandOwner?.name ?? "Company")
      }

      if viewModel.brandOwner != nil {
        Button(action: {
          viewModel.setActiveSheet(.brand)
        }) {
          Text(viewModel.brand?.name ?? "Brand")
        }
        .disabled(viewModel.brandOwner == nil)
      }

      if viewModel.brand != nil {
        Toggle("Has sub-brand?", isOn: $viewModel.hasSubBrand)
      }

      if viewModel.hasSubBrand {
        Button(action: {
          viewModel.setActiveSheet(.subBrand)
        }) {
          Text(viewModel.subBrand?.name ?? "Sub-brand")
        }
        .disabled(viewModel.brand == nil)
      }

    } header: {
      Text("Brand")
        .onTapGesture {
          self.focusedField = nil
        }
    }
    .headerProminence(.increased)
  }

  private var productSection: some View {
    Section {
      TextField("Name", text: $viewModel.name)
        .focused($focusedField, equals: .name)

      TextField("Description (optional)", text: $viewModel.description)
        .focused($focusedField, equals: .description)

      if mode == .new {
        Button(action: {
          viewModel.setActiveSheet(.barcode)
        }) {
          if viewModel.barcode != nil {
            Text("Barcode Added!")
          } else {
            Text("Add Barcode")
          }
        }
      }
    } header: {
      Text("Product")
        .onTapGesture {
          self.focusedField = nil
        }
    }
    .headerProminence(.increased)
  }
}

extension ProductSheetView {
  enum Mode {
    case new
    case edit
    case editSuggestion
  }

  enum Focusable {
    case name
    case description
  }

  enum Sheet: Identifiable {
    var id: Self { self }
    case subcategories
    case brandOwner
    case brand
    case subBrand
    case barcode
  }

  enum Toast: Identifiable {
    var id: Self { self }
    case createdCompany
    case createdBrand
    case createdSubBrand
  }

  @MainActor class ViewModel: ObservableObject {
    @Published var categories = [Category.JoinedSubcategories]()
    @Published var activeSheet: Sheet?
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

    @Published var subBrand: SubBrand?
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

    func getSubcategoriesForCategory() -> [Subcategory]? {
      category?.subcategories
    }

    func createSubcategory(newSubcategoryName: String) {
      if let categoryWithSubcategories = category {
        Task {
          switch await repository.subcategory
            .insert(newSubcategory: Subcategory
              .NewRequest(name: newSubcategoryName, category: categoryWithSubcategories))
          {
          case .success:
            await MainActor.run {
              self.loadCategories(categoryWithSubcategories.name)
            }
          case let .failure(error):
            print(error)
          }
        }
      }
    }

    func setBrand(brand: Brand.JoinedSubBrands) {
      DispatchQueue.main.async {
        self.brand = brand
        self.subBrand = brand.subBrands.first(where: { $0.name == nil })
        self.activeSheet = nil
      }
    }

    func setActiveSheet(_ sheet: Sheet) {
      DispatchQueue.main.async {
        self.activeSheet = sheet
      }
    }

    func setBrandOwner(_ brandOwner: Company) {
      DispatchQueue.main.async {
        self.brandOwner = brandOwner
      }
    }

    func dismissSheet() {
      DispatchQueue.main.async {
        self.activeSheet = nil
      }
    }

    func isValid() -> Bool {
      brandOwner != nil && brand != nil && validateStringLength(str: name, type: .normal)
    }

    func getToastText(_ toast: Toast) -> String {
      switch toast {
      case .createdCompany:
        return "New Company Created!"
      case .createdBrand:
        return "New Brand Created!"
      case .createdSubBrand:
        return "New Sub-brand Created!"
      }
    }

    func loadInitialProduct(_ initialProduct: Product.Joined?) {
      guard let initialProduct else { return }

      Task {
        // TODO: Load the missing data in parallel 18.1.2023
        switch await repository.category.getAllWithSubcategories() {
        case let .success(categories):
          switch await repository.brand
            .getByBrandOwnerId(brandOwnerId: initialProduct.subBrand.brand.brandOwner.id)
          {
          case let .success(brandsWithSubBrands):
            await MainActor.run {
              self.categories = categories
              self.category = categories.first(where: { $0.id == initialProduct.category.id })
              self.subcategories = initialProduct.subcategories.map { $0.getSubcategory() }
              self.brandOwner = initialProduct.subBrand.brand.brandOwner
              self.brand = Brand.JoinedSubBrands(
                id: initialProduct.subBrand.brand.id,
                name: initialProduct.subBrand.brand.name,
                isVerified: initialProduct.subBrand.brand.isVerified,
                subBrands: brandsWithSubBrands
                  .first(where: { $0.id == initialProduct.subBrand.brand.id })?.subBrands ?? []
              )
              self.subBrand = initialProduct.subBrand.getSubBrand()
              self.name = initialProduct.name
              self.description = initialProduct.description ?? ""
              self.hasSubBrand = initialProduct.subBrand.name != nil
            }
          case let .failure(error):
            print(error)
          }
        case let .failure(error):
          print(error)
        }
      }
    }

    func loadInitialBarcode(_ initialBarcode: Barcode?) {
      guard let initialBarcode else { return }
      DispatchQueue.main.async {
        self.barcode = initialBarcode
      }
    }

    func loadCategories(_ initialCategory: Category.Name = Category.Name.beverage) {
      Task {
        switch await repository.category.getAllWithSubcategories() {
        case let .success(categories):
          await MainActor.run {
            self.categories = categories
            self.category = categories.first(where: { $0.name == initialCategory })
          }
        case let .failure(error):
          print(error)
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
          switch await repository.product.create(newProductParams: newProductParams) {
          case let .success(newProduct):
            onCreation(newProduct)
          case let .failure(error):
            print(error)
          }
        }
      }
    }

    func createProductEditSuggestion(product: Product.Joined, onComplete: @escaping () -> Void) {
      if let subBrand, let category {
        let productEditSuggestionParams = Product.EditRequest(
          productId: product.id,
          name: name,
          description: description,
          categoryId: category.id,
          subBrandId: subBrand.id,
          subcategories: subcategories
        )

        Task {
          switch await repository.product
            .createUpdateSuggestion(productEditSuggestionParams: productEditSuggestionParams)
          {
          case .success:
            onComplete()
          case let .failure(error):
            print(error)
          }
          onComplete()
        }
      }
    }

    func editProduct(product: Product.Joined, onComplete: @escaping () -> Void) {
      if let category, let brand {
        let subBrandWithNil = subBrand == nil ? brand.subBrands.first(where: { $0.name == nil }) : subBrand
        guard let subBrandWithNil else { return }
        let productEditParams = Product.EditRequest(
          productId: product.id,
          name: name,
          description: description,
          categoryId: category.id,
          subBrandId: subBrandWithNil.id,
          subcategories: subcategories
        )

        Task {
          switch await repository.product.editProduct(productEditParams: productEditParams) {
          case .success:
            onComplete()
          case let .failure(error):
            print(error)
          }
        }
      }
    }
  }
}
