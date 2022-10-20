import AlertToast
import SwiftUI

struct AddProductScreenView: View {
    @State var categories = [CategoryJoinedWithSubcategories]()
    @State var activeSheet: Sheet?
    @EnvironmentObject var navigator: Navigator
    @State var showToast = false
    @State var toastType: ToastType?

    // New product values
    @State var category: CategoryName = CategoryName.beverage
    @State var subcategories: [Subcategory] = []
    @State var brandOwner: Company?
    @State var brand: BrandJoinedWithSubBrands?
    @State var subBrand: SubBrand?
    @State var name: String = ""
    @State var description: String = ""

    func getSubcategoriesForCategory() -> [Subcategory]? {
        return categories.first(where: { $0.name == category })?.subcategories
    }

    func setBrand(brand: BrandJoinedWithSubBrands) {
        self.brand = brand
        subBrand = nil
        dismissSheet()
    }

    func dismissSheet() {
        activeSheet = nil
    }

    func isValid() -> Bool {
        return [
            brandOwner != nil,
            brand != nil,
            subBrand != nil,
            validateStringLenght(str: name, type: .normal),
        ].allSatisfy({ $0 })
    }

    func getToastText() -> String {
        switch toastType {
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

    var body: some View {
        VStack {
            List {
                Section {
                    if categories.count > 0 {
                        Picker("Category", selection: $category) {
                            ForEach(categories.map { $0.name }) { category in
                                Text(category.rawValue.capitalized).tag(category)
                            }
                        }
                        .onChange(of: category) { _ in
                            self.subcategories.removeAll()
                        }
                    }

                    Button(action: { self.activeSheet = Sheet.subcategories }) {
                        HStack {
                            if subcategories.count == 0 {
                                Text("Subcategories")
                            } else {
                                HStack { ForEach(subcategories) { subcategory in
                                    ChipView(title: subcategory.name)
                                }}
                            }
                        }
                    }
                }
            header: {
                    Text("Category")
                }.headerProminence(.increased)

                Section {
                    Button(action: { self.activeSheet = Sheet.brandOwner }) {
                        Text(brandOwner?.name ?? "Owner")
                    }
                    Button(action: { self.activeSheet = Sheet.brand }) {
                        Text(brand?.name ?? "Brand")
                    }.disabled(brandOwner == nil)

                    Button(action: { self.activeSheet = Sheet.subBrand }) {
                        Text(subBrand?.name ?? "Sub-brand")
                    }.disabled(brand == nil)

                } header: {
                    Text("Brand")
                }.headerProminence(.increased)

                Section {
                    TextField("Flavor", text: $name)
                        .limitInputLength(value: $name, length: 24)
                    TextField("Description", text: $description)
                        .limitInputLength(value: $description, length: 24)

                } header: {
                    Text("Product")
                }.headerProminence(.increased)

                Button("Create Product", action: { createProduct() })
                    .disabled(!isValid())
            }

        }.sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .subcategories:
                if let subcategoriesForCategory = getSubcategoriesForCategory() {
                    SubcategoryPicker(availableSubcategories: subcategoriesForCategory, subcategories: $subcategories)
                }
            case .brandOwner:
                CompanySearchView(onSelect: { company, createdNew in
                    self.brandOwner = company
                    if createdNew {
                        self.toastType = ToastType.createdCompany
                        self.showToast = true
                    }
                    dismissSheet()
                })
            case .brand:
                if let brandOwner = brandOwner {
                    BrandSearchView(brandOwner: brandOwner, onSelect: { brand, createdNew in
                        if createdNew {
                            self.toastType = ToastType.createdBrand
                            self.showToast = true
                        }
                        self.setBrand(brand: brand)
                    })
                }

            case .subBrand:
                if let brand = brand {
                    SubBrandPickerView(brandWithSubBrands: brand, onSelect: { subBrand, createdNew in
                        if createdNew {
                            self.toastType = ToastType.createdSubBrand
                            self.showToast = true
                        }
                        self.subBrand = subBrand
                        dismissSheet()

                    })
                }
            }
        }
        .toast(isPresenting: $showToast, duration: 2, tapToDismiss: true) {
            AlertToast(type: .complete(.green), title: getToastText())
        }
        .task {
            loadCategories()
        }
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

    func createProduct() {
        if let subBrandId = subBrand?.id, let categoryId = categories.first(where: { $0.name == category })?.id {
            let newProductParams = NewProductParams(name: name, description: description, categoryId: categoryId, subBrandId: subBrandId, subCategoryIds: subcategories.map { $0.id })
            Task {
                do {
                    let newProduct = try await repository.product.create(newProductParams: newProductParams)
                    navigator.navigateTo(destination: newProduct, resetStack: true)
                } catch {
                    print("error: \(error)")
                }
            }
        }
    }
}

extension AddProductScreenView {
    enum Sheet: Identifiable {
        var id: Self { self }
        case subcategories
        case brandOwner
        case brand
        case subBrand
    }

    enum ToastType: Identifiable {
        var id: Self { self }
        case createdCompany
        case createdBrand
        case createdSubBrand
    }
}
