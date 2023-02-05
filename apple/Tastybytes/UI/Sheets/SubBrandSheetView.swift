import SwiftUI

struct SubBrandSheetView: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.dismiss) private var dismiss

  let brandWithSubBrands: Brand.JoinedSubBrands
  let onSelect: (_ company: SubBrand, _ createdNew: Bool) -> Void

  init(
    _ client: Client,
    brandWithSubBrands: Brand.JoinedSubBrands,
    onSelect: @escaping (_ company: SubBrand, _ createdNew: Bool) -> Void
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
    self.brandWithSubBrands = brandWithSubBrands
    self.onSelect = onSelect
  }

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
    private let logger = getLogger(category: "SubBrandSheetView")
    let client: Client
    @Published var subBrandName = ""

    init(_ client: Client) {
      self.client = client
    }

    func createNewSubBrand(
      _ brand: Brand.JoinedSubBrands,
      _ onSelect: @escaping (_ subBrand: SubBrand, _ createdNew: Bool) -> Void
    ) {
      Task {
        switch await client.subBrand
          .insert(newSubBrand: SubBrand.NewRequest(name: subBrandName, brandId: brand.id))
        {
        case let .success(newSubBrand):
          onSelect(newSubBrand, true)
        case let .failure(error):
          logger
            .error(
              "saving sub-brand \(self.subBrandName) failed: \(error.localizedDescription)"
            )
        }
      }
    }
  }
}
