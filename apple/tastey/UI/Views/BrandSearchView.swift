import SwiftUI

struct BrandSearchView: View {
    let brandOwner: Company
    @State var searchText = ""
    @State var brandsWithSubBrands = [BrandJoinedWithSubBrands]()
    @State var brandName = ""
    @Environment(\.dismiss) var dismiss
    
    let onSelect: (_ company: BrandJoinedWithSubBrands, _ createdNew: Bool) -> Void
    
    var body: some View {
        
        NavigationStack {
            List {
                ForEach(brandsWithSubBrands, id: \.self) { brand in
                    Button(action: {self.onSelect(brand, false)}) {
                        Text(brand.name)
                    }
                }
                
                Section {
                    TextField("Name", text: $brandName)
                    Button("Create") {
                        createNewBrand()
                    }.disabled(!validateStringLength(str: brandName, type: .normal))
                } header: {
                    Text("Add new brand for \(brandOwner.name)")
                }
            }
            .navigationTitle("Add brand name")
            .navigationBarItems(trailing: Button(action: {
                dismiss()
            }) {
                Text("Cancel").bold()
            })
            
        }.task {
            loadBrands()
        }
    }
    
    func loadBrands() {
        Task {
            do {
                let brandsWithSubBrands = try await repository.brand.getByBrandOwnerId(brandOwnerId: brandOwner.id)
                DispatchQueue.main.async {
                    self.brandsWithSubBrands = brandsWithSubBrands
                }
            } catch {
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    func createNewBrand() {
        let newBrand = NewBrand(name: brandName, brandOwnerId: brandOwner.id)
        Task {
            do {
                let brandWithSubBrands = try await repository.brand.insert(newBrand: newBrand)
                DispatchQueue.main.async {
                    onSelect(brandWithSubBrands, true)
                }
            } catch {
                print("error: \(error.localizedDescription)")
            }
        }
    }
}
