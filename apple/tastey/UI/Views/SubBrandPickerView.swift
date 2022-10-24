import SwiftUI

struct SubBrandPickerView: View {
    let brandWithSubBrands: BrandJoinedWithSubBrands
    let onSelect: (_ company: SubBrand, _ createdNew: Bool) -> Void

    @StateObject private var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss

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
                    TextField("Name", text: $viewModel.subBrandName)
                        .limitInputLength(value: $viewModel.subBrandName, length: 24)
                    Button("Create") {
                        viewModel.createNewSubBrand(brandWithSubBrands, onSelect)
                    }
                    .disabled(!validateStringLenght(str: viewModel.subBrandName, type: .normal))
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
}

extension SubBrandPickerView {
    @MainActor class ViewModel: ObservableObject {
        @Published var subBrandName = ""
        
        func createNewSubBrand(_ brand: BrandJoinedWithSubBrands, _ onSelect: @escaping (_ subBrand: SubBrand,  _ createdNew: Bool) -> Void) {
            let newSubBrand = SubBrandNew(name: subBrandName, brandId: brand.id)
            Task {
                do {
                    let newSubBrand = try await repository.subBrand.insert(newSubBrand: newSubBrand)
                    
                    DispatchQueue.main.async {
                        onSelect(newSubBrand, true)
                    }
                } catch {
                    print("error: \(error.localizedDescription)")
                }
            }
        }
    }
}
