import SwiftUI

struct SubBrandPickerView: View {
    let brandWithSubBrands: BrandJoinedWithSubBrands
    @State var searchText = ""
    @State var subBrandName = ""
    @Environment(\.dismiss) var dismiss

    let onSelect: (_ company: SubBrand, _ createdNew: Bool) -> Void

    var body: some View {

        NavigationStack {
            List {
                ForEach(brandWithSubBrands.subBrands, id: \.self) { subBrand in
                    Button(action: {self.onSelect(subBrand, false)}) {
                        if let name = subBrand.name {
                            Text(name)
                        }
                    }
                }
                                
                Section {
                    TextField("Name", text: $subBrandName)
                        .limitInputLength(value: $subBrandName, length: 24)
                    Button("Create") {
                        createNewSubBrand()
                    }
                } header: {
                    Text("Add new sub-brand for \(brandWithSubBrands.name)")
                }
            }
            .navigationTitle("Sub-brands")
            .navigationBarItems(trailing: Button(action: {
                dismiss()
            }) {
                Text("Cancel").bold()
            })
            
        }
    }
    
    func createNewSubBrand() {
        let newSubBrand = SubBrandNew(name: subBrandName, brandId: brandWithSubBrands.id)
        Task {
            do {
                let newSubBrand = try await SupabaseSubBrandRepository().insert(newSubBrand: newSubBrand)
                
                DispatchQueue.main.async {
                    onSelect(newSubBrand, true)
                }
            } catch {
                print("error: \(error.localizedDescription)")
            }
        }
    }
}
