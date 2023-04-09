import SwiftUI

struct SubBrandSheet: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.dismiss) private var dismiss

  let onSelect: (_ company: SubBrand, _ createdNew: Bool) -> Void

  init(
    _ client: Client,
    brandWithSubBrands: Brand.JoinedSubBrands,
    onSelect: @escaping (_ company: SubBrand, _ createdNew: Bool) -> Void
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, brandWithSubBrands: brandWithSubBrands))
    self.onSelect = onSelect
  }

  var body: some View {
    List {
      ForEach(viewModel.filteredSubBrands) { subBrand in
        if let name = subBrand.name {
          Button(action: {
            onSelect(subBrand, false)
            dismiss()
          }, label: {
            Text(name)
          })
        }
      }

      if profileManager.hasPermission(.canCreateBrands) {
        Section {
          TextField("Name", text: $viewModel.subBrandName)
          Button("Create") {
            viewModel.createNewSubBrand(onSelect)
          }
          .disabled(!viewModel.subBrandName.isValidLength(.normal))
        } header: {
          Text("Add new sub-brand for \(viewModel.brandWithSubBrands.name)")
        }
      }
    }
    .navigationTitle("Sub-brands")
    .navigationBarItems(trailing: Button(role: .cancel, action: { dismiss() }, label: {
      Text("Cancel").bold()
    }))
  }
}
