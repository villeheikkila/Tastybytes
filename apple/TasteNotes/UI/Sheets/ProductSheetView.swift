import SwiftUI

struct ProductSheetView: View {
    @EnvironmentObject var routeManager: RouteManager
    @EnvironmentObject var toastManager: ToastManager
    @StateObject var viewModel = ViewModel()
    let initialProduct: ProductJoined?
    let initialBarcode: Barcode?

    init(initialProduct: ProductJoined? = nil, initialBarcode: Barcode? = nil) {
        self.initialProduct = initialProduct
        self.initialBarcode = initialBarcode
    }

    var body: some View {
        VStack {
            List {
                categorySection
                brandSection
                productSection

                Button(initialProduct == nil ? "Create Product" : "Send edit suggestion", action: {
                    if let initialProduct = initialProduct {
                        viewModel.createProductEditSuggestion(product: initialProduct, onComplete: {
                            print("hei")
                        })

                    } else {
                        viewModel.createProduct(onCreation: {
                            product in routeManager.navigateTo(destination: product, resetStack: true)
                        })
                    }
                })
                .disabled(!viewModel.isValid())
            }

        }
        .sheet(item: $viewModel.activeSheet) { sheet in
            switch sheet {
            case .subcategories:
                if let subcategoriesForCategory = viewModel.getSubcategoriesForCategory() {
                    SubcategorySheetView(availableSubcategories: subcategoriesForCategory, subcategories: $viewModel.subcategories)
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
                            viewModel.subBrand = subBrand
                        }
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
        .task {
            viewModel.loadInitialProduct(initialProduct)
            viewModel.loadInitialBarcode(initialBarcode)
        }
        .task {
            viewModel.loadCategories()
        }
    }

    var categorySection: some View {
        Section {
            if viewModel.categories.count > 0 {
                Picker("Category", selection: $viewModel.category) {
                    ForEach(viewModel.categories.map { $0.name }) { category in
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
        }
        .headerProminence(.increased)
    }

    var productSection: some View {
        Section {
            TextField("Flavor", text: $viewModel.name)
            TextField("Description (optional)", text: $viewModel.description)
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
        }
        .headerProminence(.increased)
    }
}

extension ProductSheetView {
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
        @Published var categories = [CategoryJoinedWithSubcategories]()
        @Published var activeSheet: Sheet?
        @Published var category: CategoryName = CategoryName.beverage
        @Published var subcategories: [Subcategory] = []
        @Published var brandOwner: Company?
        @Published var brand: BrandJoinedWithSubBrands?
        @Published var subBrand: SubBrand?
        @Published var name: String = ""
        @Published var description: String = ""
        @Published var hasSubBrand = false
        @Published var barcode: Barcode? = nil

        func getSubcategoriesForCategory() -> [Subcategory]? {
            return categories.first(where: { $0.name == category })?.subcategories
        }

        func setBrand(brand: BrandJoinedWithSubBrands) {
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

        func loadInitialProduct(_ initialProduct: ProductJoined?) {
            guard let initialProduct = initialProduct else { return }

            category = initialProduct.getCategory() ?? CategoryName.beverage
            subcategories = initialProduct.subcategories.map { $0.getSubcategory() }
            brandOwner = initialProduct.subBrand.brand.brandOwner
            brand = BrandJoinedWithSubBrands(id: initialProduct.subBrand.brand.id, name: initialProduct.subBrand.brand.name, subBrands: []) // TODO: Fetch sub-brands
            subBrand = initialProduct.subBrand.getSubBrand()
            name = initialProduct.name
            description = initialProduct.description ?? ""
            hasSubBrand = initialProduct.subBrand.name != nil
        }
        
        func loadInitialBarcode(_ initialBarcode: Barcode?) {
            guard let initialBarcode = initialBarcode else { return }
            
            DispatchQueue.main.async {
                self.barcode = initialBarcode
            }
        }

        func loadCategories() {
            Task {
                switch await repository.category.getAllWithSubcategories() {
                case let .success(categories):
                    await MainActor.run {
                        self.categories = categories
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }

        func createProduct(onCreation: @escaping (_ product: ProductJoined) -> Void) {
            if let categoryId = categories.first(where: { $0.name == category })?.id, let brandId = brand?.id {
                let newProductParams = NewProductParams(name: name, description: description, categoryId: categoryId, brandId: brandId, subBrandId: subBrand?.id, subCategoryIds: subcategories.map { $0.id })
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

        func createProductEditSuggestion(product: ProductJoined, onComplete: @escaping () -> Void) {
            if let subBrand = subBrand {
                let productEditSuggestionParams = NewProductEditSuggestionParams(productId: product.id, name: name, description: description, categoryId: product.subcategories.first!.category.id, subBrandId: subBrand.id, subCategoryIds: subcategories.map { $0.id })
                print(productEditSuggestionParams)
                Task {
                    switch await repository.product.createUpdateSuggestion(productEditSuggestionParams: productEditSuggestionParams) {
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
