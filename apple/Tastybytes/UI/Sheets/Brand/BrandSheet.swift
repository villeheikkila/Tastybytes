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
          Button(brand.name, action: {
            onSelect(brand, false)
            dismiss()
          })
        }
      }

      if profileManager.hasPermission(.canCreateBrands) {
        Section {
          TextField("Name", text: $viewModel.brandName)
          ProgressButton("Create") {
            await viewModel.createNewBrand(brandOwner) { brand in
              onSelect(brand, true)
              dismiss()
            }
          }
          .disabled(!viewModel.brandName.isValidLength(.normal))
        } header: {
          Text("Add new brand for \(brandOwner.name)")
        }
      }
    }
    .navigationTitle("\(viewModel.mode == .select ? "Select" : "Add") brand")
    .navigationBarItems(trailing: Button("Cancel", role: .cancel, action: { dismiss() }).bold())
    .task {
      await viewModel.loadBrands(brandOwner)
    }
  }
}
