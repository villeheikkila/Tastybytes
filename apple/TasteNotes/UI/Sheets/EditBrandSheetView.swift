import SwiftUI

struct EditBrandSheetView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = ViewModel()
    @State var name: String
    @State var brandOwner: Company

    let brand: Brand.JoinedSubBrandsProducts
    let onUpdate: () -> Void

    init(brand: Brand.JoinedSubBrandsProducts, brandOwner: Company, onUpdate: @escaping () -> Void) {
        self.brand = brand
        _brandOwner = State(initialValue: brandOwner)
        _name = State(initialValue: brand.name)
        self.onUpdate = onUpdate
    }

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                Button(action: {
                    viewModel.activeSheet = Sheet.brandOwner
                }) {
                    Text(brandOwner.name)
                }
                Button("Edit") {
                    viewModel.editBrand(brand: brand, name: name, brandOwner: brandOwner) {
                        dismiss()
                        onUpdate()
                    }
                }
                .disabled(!validateStringLength(str: name, type: .normal))
            } header: {
                Text("Brand name")
            }
        }
        .navigationTitle("Edit Brand")
        .navigationBarItems(trailing: Button(action: {
            dismiss()
        }) {
            Text("Cancel").bold()
        })
        .sheet(item: $viewModel.activeSheet) { sheet in NavigationStack {
            switch sheet {
            case .brandOwner:
                CompanySheetView(onSelect: { company, _ in
                    brandOwner = company
                    viewModel.activeSheet = nil
                })
            }
        }
        }
    }
}

extension EditBrandSheetView {
    enum Sheet: Identifiable {
        var id: Self { self }
        case brandOwner
    }

    @MainActor class ViewModel: ObservableObject {
        @Published var activeSheet: Sheet?

        func editBrand(brand: Brand.JoinedSubBrandsProducts, name: String, brandOwner: Company, onSuccess: @escaping () -> Void) {
            Task {
                switch await repository.brand.update(updateRequest: Brand.UpdateRequest(id: brand.id, name: name, brandOwnerId: brandOwner.id)) {
                case .success:
                    onSuccess()
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
}
