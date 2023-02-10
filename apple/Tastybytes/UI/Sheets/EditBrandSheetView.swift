import AlertToast
import SwiftUI

struct EditBrandSheetView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: ViewModel

  let onUpdate: () -> Void

  init(
    _ client: Client,
    brand: Brand.JoinedSubBrandsProductsCompany,
    onUpdate: @escaping () -> Void
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, brand: brand))
    self.onUpdate = onUpdate
  }

  var body: some View {
    Form {
      Section {
        TextField("Name", text: $viewModel.name)
        Button("Edit") {
          viewModel.editBrand {
            onUpdate()
          }
        }.disabled(!validateStringLength(str: viewModel.name, type: .normal) || viewModel.brand.name == viewModel.name)
      } header: {
        Text("Brand name")
      }

      Section {
        Button(action: {
          viewModel.activeSheet = Sheet.brandOwner
        }) {
          Text(viewModel.brandOwner.name)
        }
        Button("Change brand owner") {
          viewModel.editBrand {
            onUpdate()
          }
        }.disabled(viewModel.brandOwner.id == viewModel.initialBrandOwner.id)
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
          viewModel.brandOwner = company
          viewModel.activeSheet = nil
        })
      }
    }
    }
    .toast(isPresenting: $viewModel.showToast, duration: 2, tapToDismiss: true) {
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
    @Published var name: String
    @Published var brandOwner: Company
    @Published var showToast = false
    @Published var initialBrandOwner: Company
    @Published var brand: Brand.JoinedSubBrandsProductsCompany

    init(_ client: Client, brand: Brand.JoinedSubBrandsProductsCompany) {
      self.client = client
      self.brand = brand
      initialBrandOwner = brand.brandOwner
      brandOwner = brand.brandOwner
      name = brand.name
    }

    func editBrand(
      onSuccess: @escaping () -> Void
    ) {
      Task {
        switch await client.brand
          .update(updateRequest: Brand.UpdateRequest(id: brand.id, name: name, brandOwnerId: brandOwner.id))
        {
        case .success:
          showToast.toggle()
          onSuccess()
        case let .failure(error):
          logger.error("failed to edit brand '\(self.brand.id)': \(error.localizedDescription)")
        }
      }
    }
  }
}
