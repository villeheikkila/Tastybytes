import SwiftUI

struct SubBrandSheet: View {
  private let logger = getLogger(category: "SubBrandSheet")
  @EnvironmentObject private var client: AppClient
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.dismiss) private var dismiss
  @State private var subBrandName = ""

  let brandWithSubBrands: Brand.JoinedSubBrands
  let onSelect: (_ company: SubBrand, _ createdNew: Bool) -> Void

  init(
    brandWithSubBrands: Brand.JoinedSubBrands,
    onSelect: @escaping (_ company: SubBrand, _ createdNew: Bool) -> Void
  ) {
    self.brandWithSubBrands = brandWithSubBrands
    self.onSelect = onSelect
  }

  var filteredSubBrands: [SubBrand] {
    brandWithSubBrands.subBrands.filter { $0.name != nil }
  }

  var body: some View {
    List {
      ForEach(filteredSubBrands) { subBrand in
        if let name = subBrand.name {
          Button(name, action: {
            onSelect(subBrand, false)
            dismiss()
          })
        }
      }

      if profileManager.hasPermission(.canCreateBrands) {
        Section("Add new sub-brand for \(brandWithSubBrands.name)") {
          TextField("Name", text: $subBrandName)
          ProgressButton("Create") {
            await createNewSubBrand { subBrand, createdNew in
              onSelect(subBrand, createdNew)
              dismiss()
            }
          }
          .disabled(!subBrandName.isValidLength(.normal))
        }
      }
    }
    .navigationTitle("Sub-brands")
    .navigationBarItems(trailing: Button("Cancel", role: .cancel, action: { dismiss() }).bold())
  }

  func createNewSubBrand(
    onSelect: @escaping (_ subBrand: SubBrand, _ createdNew: Bool) -> Void
  ) async {
    switch await client.subBrand
      .insert(newSubBrand: SubBrand.NewRequest(name: subBrandName, brandId: brandWithSubBrands.id))
    {
    case let .success(newSubBrand):
      onSelect(newSubBrand, true)
    case let .failure(error):
      logger.error("saving sub-brand failed: \(error.localizedDescription)")
    }
  }
}
