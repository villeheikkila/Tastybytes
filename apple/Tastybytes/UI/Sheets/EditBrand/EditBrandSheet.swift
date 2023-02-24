import AlertToast
import SwiftUI

struct EditBrandSheet: View {
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
        Button(action: { viewModel.activeSheet = Sheet.brandOwner }, label: {
          Text(viewModel.brandOwner.name)
        })
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
    .navigationBarItems(trailing: Button(action: { dismiss() }, label: {
      Text("Done").bold()
    }))
    .sheet(item: $viewModel.activeSheet) { sheet in NavigationStack {
      switch sheet {
      case .brandOwner:
        CompanySearchSheet(viewModel.client, onSelect: { company, _ in
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
