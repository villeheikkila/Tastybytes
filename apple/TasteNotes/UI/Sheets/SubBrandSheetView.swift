import SwiftUI

struct SubBrandSheetView: View {
    @EnvironmentObject private var profileManager: ProfileManager
    let brandWithSubBrands: Brand.JoinedSubBrands
    let onSelect: (_ company: SubBrand, _ createdNew: Bool) -> Void

    @StateObject private var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            ForEach(brandWithSubBrands.subBrands.filter { $0.name != nil }, id: \.self) { subBrand in
                Button(action: { self.onSelect(subBrand, false) }) {
                    if let name = subBrand.name {
                        Text(name)
                    }
                }
            }

            if profileManager.hasPermission(.canCreateBrands) {
                Section {
                    TextField("Name", text: $viewModel.subBrandName)
                    Button("Create") {
                        viewModel.createNewSubBrand(brandWithSubBrands, onSelect)
                    }
                    .disabled(!validateStringLength(str: viewModel.subBrandName, type: .normal))
                } header: {
                    Text("Add new sub-brand for \(brandWithSubBrands.name)")
                }
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

extension SubBrandSheetView {
    @MainActor class ViewModel: ObservableObject {
        @Published var subBrandName = ""

        func createNewSubBrand(_ brand: Brand.JoinedSubBrands, _ onSelect: @escaping (_ subBrand: SubBrand, _ createdNew: Bool) -> Void) {
            Task {
                switch await repository.subBrand.insert(newSubBrand: SubBrand.NewRequest(name: subBrandName, brandId: brand.id)) {
                case let .success(newSubBrand):
                    await MainActor.run {
                        onSelect(newSubBrand, true)
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
}
