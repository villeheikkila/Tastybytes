import SwiftUI

struct ProductSheetView: View {
  @EnvironmentObject private var routeManager: RouteManager
  @EnvironmentObject private var toastManager: ToastManager
  @StateObject private var viewModel = ViewModel()
  @State private var mode = Mode.new
  @FocusState private var focusedField: Focusable?

  let initialProduct: Product.Joined?
  let initialBarcode: Barcode?
  let onEdit: (() -> Void)?

  init(mode: Mode, initialProduct: Product.Joined? = nil, initialBarcode: Barcode? = nil, onEdit: (() -> Void)? = nil) {
        self.mode = mode
        self.initialProduct = initialProduct
        self.initialBarcode = initialBarcode
        self.onEdit = onEdit
    }

  var doneLabel: String {
    switch mode {
    case .edit:
      return "Edit"
    case .editSuggestion:
      return "Send Edit suggestion"
    case .new:
      return "Create"
  }

  var navigationTitle: String {
    switch mode {
    case .edit:
      return "Edit Product"
    case .editSuggestion:
      return "Edit Suggestion"
    case .new:
      return "Add Product"
    }
  }
    
    var body: some View {
        List {
            categorySection
            brandSection
            productSection

            Button(doneLabel, action: {
                switch mode {
                case .editSuggestion:
                    if let initialProduct = initialProduct {
                        viewModel.createProductEditSuggestion(product: initialProduct, onComplete: {
                            toastManager.toggle(.success("Edit suggestion sent!"))
                        })
                    }
                case .edit:
                    if let initialProduct = initialProduct {
                        viewModel.editProduct(product: initialProduct, onComplete: {
                            if let onEdit = onEdit {
                                onEdit()
                            }
                        })
                    }
                case .new:
                    viewModel.createProduct(onCreation: {
                        product in routeManager.navigateTo(destination: product, resetStack: true)
                    })
                }
            })
          }
        case .edit:
          if let initialProduct {
            viewModel.editProduct(product: initialProduct, onComplete: {
              print("hei")
            })
          }
        case .new:
          viewModel.createProduct(onCreation: {
            product in routeManager.navigateTo(destination: product, resetStack: true)
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
              availableSubcategories: subcategoriesForCategory,
              subcategories: $viewModel.subcategories,
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
          .presentationDetents([.medium])
        }
      }
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

  var categorySection: some View {
    Section {
      if viewModel.categories.count > 0 {
        Picker("Category", selection: $viewModel.categoryName) {
          ForEach(viewModel.categories.map(\.name)) { category in
            Text(category.getName).tag(category)
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

  var brandSection: some View {
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

    var productSection: some View {
        Section {
            TextField("Flavor", text: $viewModel.name)
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
    }
    .headerProminence(.increased)
  }

  var productSection: some View {
    Section {
      TextField("Flavor", text: $viewModel.name)
        .focused($focusedField, equals: .name)
      TextField("Description (optional)", text: $viewModel.description)
        .focused($focusedField, equals: .description)
      Button(action: {
        viewModel.setActiveSheet(.barcode)
      }) {
        if viewModel.barcode != nil {
          Text("Barcode Added!")
        } else {
          Text("Add Barcode")
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
      // TODO: Investigate if this cna be avoided by passing ServingStyle directly to the picker
      didSet {
        category = categories.first(where: { $0.name == categoryName })
      }
    }

    @Published var category: Category.JoinedSubcategories?
    @Published var subcategories: [Subcategory] = []
    @Published var brandOwner: Company?
    @Published var brand: Brand.JoinedSubBrands?
    @Published var subBrand: SubBrand?
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var hasSubBrand = false
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

    @MainActor class ViewModel: ObservableObject {
        @Published var categories = [Category.JoinedSubcategories]()
        @Published var activeSheet: Sheet?
        @Published var categoryName: Category.Name = Category.Name.beverage {
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
        @Published var barcode: Barcode? = nil

        func getSubcategoriesForCategory() -> [Subcategory]? {
            return category?.subcategories
        }

        func createSubcategory(newSubcategoryName: String) {
            if let categoryWithSubcategories = category {
                Task {
                    switch await repository.subcategory.insert(newSubcategory: Subcategory.NewRequest(name: newSubcategoryName, category: categoryWithSubcategories)) {
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
            return brandOwner != nil && brand != nil && validateStringLength(str: name, type: .normal)
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
            guard let initialProduct = initialProduct else { return }

            Task {
                switch await repository.category.getAllWithSubcategories() {
                case let .success(categories):
                    await MainActor.run {
                        self.categories = categories
                        self.category = categories.first(where: { $0.id == initialProduct.category.id })
                        self.subcategories = initialProduct.subcategories.map { $0.getSubcategory() }
                        self.brandOwner = initialProduct.subBrand.brand.brandOwner
                        self.brand = Brand.JoinedSubBrands(id: initialProduct.subBrand.brand.id, name: initialProduct.subBrand.brand.name, isVerified: initialProduct.subBrand.brand.isVerified, subBrands: []) // TODO: Fetch sub-brands
                        self.subBrand = initialProduct.subBrand.getSubBrand()
                        self.name = initialProduct.name
                        self.description = initialProduct.description ?? ""
                        self.hasSubBrand = initialProduct.subBrand.name != nil
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }

        func loadInitialBarcode(_ initialBarcode: Barcode?) {
            guard let initialBarcode = initialBarcode else { return }
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
            if let category = category, let brandId = brand?.id {
                let newProductParams = Product.NewRequest(name: name, description: description, categoryId: category.id, brandId: brandId, subBrandId: subBrand?.id, subCategoryIds: subcategories.map { $0.id }, barcode: barcode)
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
            if let subBrand = subBrand, let category = category {
                let productEditSuggestionParams = Product.EditRequest(productId: product.id, name: name, description: description, categoryId: category.id, subBrandId: subBrand.id, subcategories: subcategories)

                Task {
                    switch await repository.product.createUpdateSuggestion(productEditSuggestionParams: productEditSuggestionParams) {
                    case .success(_):
                        onComplete()
                    case let .failure(error):
                        print(error)
                    }
                    onComplete()
                }
            }
        }
        
        func editProduct(product: Product.Joined, onComplete: @escaping () -> Void) {
            if let subBrand = subBrand, let category = category {
                let productEditParams = Product.EditRequest(productId: product.id, name: name, description: description, categoryId: category.id, subBrandId: subBrand.id, subcategories: subcategories)
                
                Task {
                    switch await repository.product.editProduct(productEditParams: productEditParams) {
                    case .success():
                        onComplete()
                    case let .failure(error):
                        print(error)
                    }
                }
            }
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
        switch await repository.category.getAllWithSubcategories() {
        case let .success(categories):
          await MainActor.run {
            self.categories = categories
            self.category = categories.first(where: { $0.id == initialProduct.category.id })
            self.subcategories = initialProduct.subcategories.map { $0.getSubcategory() }
            self.brandOwner = initialProduct.subBrand.brand.brandOwner
            self.brand = Brand.JoinedSubBrands(
              id: initialProduct.subBrand.brand.id,
              name: initialProduct.subBrand.brand.name,
              isVerified: initialProduct.subBrand.brand.isVerified,
              subBrands: []
            ) // TODO: Fetch sub-brands
            self.subBrand = initialProduct.subBrand.getSubBrand()
            self.name = initialProduct.name
            self.description = initialProduct.description ?? ""
            self.hasSubBrand = initialProduct.subBrand.name != nil
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
      if let subBrand {
        let productEditSuggestionParams = Product.EditSuggestionRequest(
          productId: product.id,
          name: name,
          description: description,
          categoryId: product.subcategories.first!.category.id,
          subBrandId: subBrand.id,
          subCategoryIds: subcategories.map(\.id)
        )

        Task {
          switch await repository.product
            .createUpdateSuggestion(productEditSuggestionParams: productEditSuggestionParams)
          {
          case let .success(data):
            print(data)
            onComplete()
          case let .failure(error):
            print(error)
          }
          onComplete()
        }
      }
    }

    func editProduct(product: Product.Joined, onComplete: @escaping () -> Void) {
      if let subBrand {
        let productEditParams = Product.EditSuggestionRequest(
          productId: product.id,
          name: name,
          description: description,
          categoryId: product.subcategories.first!.category.id,
          subBrandId: subBrand.id,
          subCategoryIds: subcategories.map(\.id)
        )

        print(productEditParams)

        Task {
          switch await repository.product.editProduct(productEditParams: productEditParams) {
          case let .success(data):
            print(data)
            onComplete()
          case let .failure(error):
            print(error)
          }
          onComplete()
        }
      }
    }
  }
}
