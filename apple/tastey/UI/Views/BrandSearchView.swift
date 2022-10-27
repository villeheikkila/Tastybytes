import SwiftUI

struct BrandSearchView: View {
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

extension BrandSearchView {
    @MainActor class ViewModel: ObservableObject {
        @Published var searchText = ""
        @Published var brandsWithSubBrands = [BrandJoinedWithSubBrands]()
        @Published var brandName = ""

        func loadBrands(_ brandOwner: Company) {
            Task {
                do {
                    let brandsWithSubBrands = try await repository.brand.getByBrandOwnerId(brandOwnerId: brandOwner.id)
                    await MainActor.run {
                        self.brandsWithSubBrands = brandsWithSubBrands
                    }
                } catch {
                    print("error: \(error.localizedDescription)")
                }
            }
        }

        func createNewBrand(_ brandOwner: Company, _ onCreation: @escaping (_ brand: BrandJoinedWithSubBrands) -> Void) {
            let newBrand = NewBrand(name: brandName, brandOwnerId: brandOwner.id)
            Task {
                do {
                    let brandWithSubBrands = try await repository.brand.insert(newBrand: newBrand)
                    onCreation(brandWithSubBrands)
                } catch {
                    print("error: \(error.localizedDescription)")
                }
            }
        }
    }
}
