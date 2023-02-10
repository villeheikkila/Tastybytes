import AlertToast
import SwiftUI

struct EditBrandSheetView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: ViewModel
  @State private var name: String
  @State private var brandOwner: Company
  @State private var showToast = false

  let initialBrandOwner: Company
  let brand: Brand.JoinedSubBrandsProductsCompany
  let onUpdate: () -> Void

  init(
    _ client: Client,
    brand: Brand.JoinedSubBrandsProductsCompany,
    onUpdate: @escaping () -> Void
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
    self.brand = brand
    initialBrandOwner = brand.brandOwner
    _brandOwner = State(initialValue: brand.brandOwner)
    _name = State(initialValue: brand.name)
    self.onUpdate = onUpdate
  }

  var body: some View {
    Form {
      Section {
        TextField("Name", text: $name)
        Button("Edit") {
          viewModel.editBrand(brand: brand, name: name, brandOwner: brandOwner) {
            onUpdate()
            showToast.toggle()
          }
        }.disabled(!validateStringLength(str: name, type: .normal) || brand.name == name)
      } header: {
        Text("Brand name")
      }

      Section {
        Button(action: {
          viewModel.activeSheet = Sheet.brandOwner
        }) {
          Text(brandOwner.name)
        }
        Button("Change brand owner") {
          viewModel.editBrand(brand: brand, name: name, brandOwner: brandOwner) {
            onUpdate()
            showToast.toggle()
          }
        }.disabled(brandOwner.id == initialBrandOwner.id)
      } header: {
        Text("Brand Owner")
      }
    }
    .navigationTitle("Edit Brand")
    .navigationBarItems(trailing: Button(action: {
      dismiss()
    }) {
      Text("Done").bold()
    })
    .sheet(item: $viewModel.activeSheet) { sheet in NavigationStack {
      switch sheet {
      case .brandOwner:
        CompanySheetView(viewModel.client, onSelect: { company, _ in
          brandOwner = company
          viewModel.activeSheet = nil
        })
      }
    }
    }
    .toast(isPresenting: $showToast, duration: 2, tapToDismiss: true) {
      AlertToast(type: .complete(.green), title: "Brand updated!")
    }
  }
}

extension EditBrandSheetView {
  enum Sheet: Identifiable {
    var id: Self { self }
    case brandOwner
  }

  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "EditBrandSheetView")
    let client: Client
    @Published var activeSheet: Sheet?

    init(_ client: Client) {
      self.client = client
    }

    func editBrand(
      brand: Brand.JoinedSubBrandsProductsCompany,
      name: String,
      brandOwner: Company,
      onSuccess: @escaping () -> Void
    ) {
      Task {
        switch await client.brand
          .update(updateRequest: Brand.UpdateRequest(id: brand.id, name: name, brandOwnerId: brandOwner.id))
        {
        case .success:
          onSuccess()
        case let .failure(error):
          logger.error("failed to edit brand '\(brand.id)': \(error.localizedDescription)")
        }
      }
    }
  }
}
