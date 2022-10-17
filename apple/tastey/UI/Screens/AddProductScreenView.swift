import SwiftUI

struct AddProductScreenView: View {
    @State var categories = [CategoryJoinedWithSubcategories]()
    @State var activeSheet: Sheet?

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
    
    func setBrand(brand: BrandJoinedWithSubBrands) -> Void {
        self.brand = brand
        self.subBrand = nil
        dismissSheet()
    }
    
    func dismissSheet() -> Void {
        self.activeSheet = nil
    }
    
    func isValid() -> Bool {
        return [
            brandOwner != nil,
            brand != nil,
            subBrand != nil,
            name != "",
            
        ].allSatisfy({$0})
    }
    
    var body: some View {
        VStack {
            List {
                Section {
                    if categories.count > 0 {
                        Picker("Main category", selection: $category) {
                            ForEach(categories.map { $0.name }) { category in
                                Text(category.rawValue.capitalized).tag(category)
                            }
                        }
                    }
                    
                    Button(action: { self.activeSheet = Sheet.subcategories }) {
                        HStack {
                            Text("Subcategories")
                            Spacer()
                            HStack { ForEach(subcategories) { subcategory in
                                ChipView(title: subcategory.name)
                            }}
                        }
                    }
                }
            header: {
                Text("Category")
            }.headerProminence(.increased)
                
                Section {
                    Button(action: { self.activeSheet = Sheet.brandOwner }) {
                        HStack {
                            Text(brandOwner?.name ?? "Brand owner")
                            Spacer()
                        }
                    }
                    Button(action: { self.activeSheet = Sheet.brand }) {
                        HStack {
                            Text(brand?.name ?? "Brand")
                            Spacer()
                        }
                    }.disabled(brandOwner == nil)
                    Button(action: { self.activeSheet = Sheet.subBrand }) {
                        HStack {
                            Text(subBrand?.name ?? "Sub-brand")
                            Spacer()
                        }
                    }.disabled(brand == nil)
                    
                } header: {
                    Text("Brand")
                }.headerProminence(.increased)
                
                Section {
                    TextField("Flavor", text: $name)
                    TextField("Description", text: $description)

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
                CompanySearchView(onSelect: { company in
                    self.brandOwner = company
                    dismissSheet()
                })
            case .brand:
                if let brandOwner = brandOwner {
                    BrandSearchView(brandOwner: brandOwner, onSelect: { brand in
                        self.setBrand(brand: brand)
                    })
                }
                
            case .subBrand:
                if let subBrands = brand?.subBrands {
                    SubBrandPickerView(subBrands: subBrands, onSelect: { subBrand in
                        self.subBrand = subBrand
                        dismissSheet()
                        
                    })
            }
            }
            
        }
        .task {
            loadCategories()
        }
    }

    func loadCategories() {
        Task {
            do {
                let categories = try await SupabaseCategoryRepository().loadAllWithSubcategories()
                self.categories = categories
            } catch {
                print("error: \(error)")
            }
        }
    }
    
    func createProduct() {
        if let subBrandId = subBrand?.id, let categoryId = categories.first(where: { $0.name == category})?.id {
            let newProductParams = NewProductParams(name: name, description: description, categoryId: categoryId, subBrandId: subBrandId, subCategoryIds: subcategories.map { $0.id })
            Task {
                do {
                    let newProduct = try await SupabaseProductRepository().createProduct(newProductParams: newProductParams )
                    
                    print(newProduct)
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
}

struct SubcategoryPicker: View {
    let availableSubcategories: [Subcategory]
    @Binding var subcategories: [Subcategory]

    var body: some View {
        NavigationView {
            List(availableSubcategories, id: \.self) { subcategory in
                ZStack {
                    Button(action: { self.subcategories.append(subcategory)
                    }) {
                        HStack {
                            Text(subcategory.name)
                            Spacer()
                            if subcategories.contains(where: { $0.id == subcategory.id }) {
                                Button(action: {
                                    self.subcategories.removeAll(where: { $0.id == subcategory.id })
                                }) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
        }.navigationBarTitle(Text("Subcategories"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                print("Dismissing sheet view...")
            }) {
                Text("Done").bold()
            })
    }
}
