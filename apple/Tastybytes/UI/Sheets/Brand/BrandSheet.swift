import SwiftUI

struct BrandSheet: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.dismiss) private var dismiss

  let brandOwner: Company
  let onSelect: (_ company: Brand.JoinedSubBrands, _ createdNew: Bool) -> Void

  init(
    _ client: Client,
    brandOwner: Company,
    mode: Mode,
    onSelect: @escaping (_ brand: Brand.JoinedSubBrands, _ createdNew: Bool) -> Void
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, mode: mode))
    self.brandOwner = brandOwner
    self.onSelect = onSelect
  }

  var body: some View {
    List {
      if viewModel.mode == .select {
        ForEach(viewModel.brandsWithSubBrands) { brand in
          Button(action: {
            onSelect(brand, false)
            dismiss()
          }, label: {
            Text(brand.name)
          })
        }
      }

      if profileManager.hasPermission(.canCreateBrands) {
        Section {
          TextField("Name", text: $viewModel.brandName)
          Button("Create") {
            viewModel.createNewBrand(brandOwner) { brand in
              onSelect(brand, true)
            }
          }
          .disabled(!viewModel.brandName.isValidLength(.normal))
        } header: {
          Text("Add new brand for \(brandOwner.name)")
        }
      }
    }
    .navigationTitle("\(viewModel.mode == .select ? "Select" : "Add") brand")
    .navigationBarItems(trailing: Button(role: .cancel, action: { dismiss() }, label: {
      Text("Cancel").bold()
    }))
    .task {
      viewModel.loadBrands(brandOwner)
    }
  }
}
