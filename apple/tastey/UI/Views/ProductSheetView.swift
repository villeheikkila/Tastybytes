import AlertToast
import SwiftUI

struct ProductSheetView: View {
    @EnvironmentObject var navigator: Navigator
    @StateObject var viewModel = ViewModel()
    let initialProduct: ProductJoined?

    init(initialProduct: ProductJoined? = nil) {
        self.initialProduct = initialProduct
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
                            product in navigator.navigateTo(destination: product, resetStack: true)
                        })
                    }
                })
                .disabled(!viewModel.isValid())
            }

        }.sheet(item: $viewModel.activeSheet) { sheet in
            switch sheet {
            case .subcategories:
                if let subcategoriesForCategory = viewModel.getSubcategoriesForCategory() {
                    SubcategoryPicker(availableSubcategories: subcategoriesForCategory, subcategories: $viewModel.subcategories)
                }
            case .brandOwner:
                CompanySearchView(onSelect: { company, createdNew in
                    viewModel.setBrandOwner(company)
                    if createdNew {
                        viewModel.setToast(.createdCompany)
                    }
                    viewModel.dismissSheet()
                })
            case .brand:
                if let brandOwner = viewModel.brandOwner {
                    BrandSearchView(brandOwner: brandOwner, onSelect: { brand, createdNew in
                        if createdNew {
                            viewModel.setToast(.createdSubBrand)
                        }
                        viewModel.setBrand(brand: brand)
                    })
                }

            case .subBrand:
                if let brand = viewModel.brand {
                    SubBrandPickerView(brandWithSubBrands: brand, onSelect: { subBrand, createdNew in
                        if createdNew {
                            viewModel.setToast(.createdSubBrand)
                            viewModel.subBrand = subBrand
                        }
                        viewModel.dismissSheet()

                    })
                }
            }
        }
        .toast(isPresenting: $viewModel.showToast, duration: 2, tapToDismiss: true) {
            AlertToast(type: .complete(.green), title: viewModel.getToastText())
        }
        .task {
            viewModel.loadInitialProduct(initialProduct)
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
        @Published var activeToast: Toast?
        @Published var showToast = false

        @Published var category: CategoryName = CategoryName.beverage
        @Published var subcategories: [Subcategory] = []
        @Published var brandOwner: Company?
        @Published var brand: BrandJoinedWithSubBrands?
        @Published var subBrand: SubBrand?
        @Published var name: String = ""
        @Published var description: String = ""
        @Published var hasSubBrand = false

        func getSubcategoriesForCategory() -> [Subcategory]? {
            return categories.first(where: { $0.name == category })?.subcategories
        }

        func setBrand(brand: BrandJoinedWithSubBrands) {
            self.brand = brand
            subBrand = nil
            activeSheet = nil
        }

        func setToast(_ toast: Toast) {
            activeToast = toast
            showToast = true
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
            return brandOwner != nil && brand != nil && validateStringLength(str: name, type: .normal)
        }

        func getToastText() -> String {
            switch activeToast {
            case .createdCompany:
                return "New Company Created!"
            case .createdBrand:
                return "New Brand Created!"
            case .createdSubBrand:
                return "New Sub-brand Created!"
            case .none:
                return ""
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

        func loadCategories() {
            Task {
                do {
                    let categories = try await repository.category.getAllWithSubcategories()
                    self.categories = categories
                } catch {
                    print("error: \(error)")
                }
            }
        }

        func createProduct(onCreation: @escaping (_ product: ProductJoined) -> Void) {
            if let categoryId = categories.first(where: { $0.name == category })?.id, let brandId = brand?.id {
                let newProductParams = NewProductParams(name: name, description: description, categoryId: categoryId, brandId: brandId, subBrandId: subBrand?.id, subCategoryIds: subcategories.map { $0.id })
                Task {
                    do {
                        let newProduct = try await repository.product.create(newProductParams: newProductParams)
                        onCreation(newProduct)
                    } catch {
                        print("error: \(error)")
                    }
                }
            }
        }

        func createProductEditSuggestion(product: ProductJoined, onComplete: @escaping () -> Void) {
            print(product)
            if let subBrand = subBrand {
                let productEditSuggestionParams = NewProductEditSuggestionParams(productId: product.id, name: name, description: description, categoryId: product.subcategories.first!.category.id, subBrandId: subBrand.id, subCategoryIds: subcategories.map { $0.id })
                print(productEditSuggestionParams)
                Task {
                    let result = await repository.product.createUpdateSuggestion(productEditSuggestionParams: productEditSuggestionParams)

                    switch result {
                    case let .success(data):
                        print(data)
                    case let .failure(error):
                        print(error)
                    }

                    onComplete()
                }
            }
        }
    }
}
