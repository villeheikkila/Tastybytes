import SwiftUI

struct BrandSheetView: View {
    let brandOwner: Company
    @StateObject var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss

    let onSelect: (_ company: BrandJoinedWithSubBrands, _ createdNew: Bool) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.brandsWithSubBrands, id: \.self) { brand in
                    Button(action: {
                        onSelect(brand, false)
                    }) {
                        Text(brand.name)
                    }
                }

                Section {
                    TextField("Name", text: $viewModel.brandName)
                    Button("Create") {
                        viewModel.createNewBrand(brandOwner, {
                            brand in onSelect(brand, true)
                        })
                    }
                    .disabled(!validateStringLength(str: viewModel.brandName, type: .normal))
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
            viewModel.loadBrands(brandOwner)
        }
    }
}

extension BrandSheetView {
    @MainActor class ViewModel: ObservableObject {
        @Published var searchText = ""
        @Published var brandsWithSubBrands = [BrandJoinedWithSubBrands]()
        @Published var brandName = ""

        func loadBrands(_ brandOwner: Company) {
            Task {
                switch await repository.brand.getByBrandOwnerId(brandOwnerId: brandOwner.id) {
                case let .success(brandsWithSubBrands):
                    await MainActor.run {
                        self.brandsWithSubBrands = brandsWithSubBrands
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }

        func createNewBrand(_ brandOwner: Company, _ onCreation: @escaping (_ brand: BrandJoinedWithSubBrands) -> Void) {
            Task {
                switch await repository.brand.insert(newBrand: NewBrand(name: brandName, brandOwnerId: brandOwner.id)) {
                case let .success(brandWithSubBrands):
                    onCreation(brandWithSubBrands)
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
}
