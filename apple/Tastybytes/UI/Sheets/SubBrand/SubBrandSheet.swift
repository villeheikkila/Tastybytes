import SwiftUI

struct SubBrandSheet: View {
  private let logger = getLogger(category: "SubBrandSheet")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @Environment(\.dismiss) private var dismiss
  @State private var subBrandName = ""

  let brandWithSubBrands: Brand.JoinedSubBrands
  let onSelect: (_ subBrand: SubBrand, _ createdNew: Bool) -> Void

  init(
    brandWithSubBrands: Brand.JoinedSubBrands,
    onSelect: @escaping (_ company: SubBrand, _ createdNew: Bool) -> Void
  ) {
    self.brandWithSubBrands = brandWithSubBrands
    self.onSelect = onSelect
  }

  var filteredSubBrands: [SubBrand] {
    brandWithSubBrands.subBrands.sorted().filter { $0.name != nil }
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
          ProgressButton("Create") { await createNewSubBrand() }
            .disabled(!subBrandName.isValidLength(.normal))
        }
      }
    }
    .navigationTitle("Sub-brands")
    .navigationBarItems(trailing: Button("Cancel", role: .cancel, action: { dismiss() }).bold())
  }

  func createNewSubBrand() async {
    switch await repository.subBrand
      .insert(newSubBrand: SubBrand.NewRequest(name: subBrandName, brandId: brandWithSubBrands.id))
    {
    case let .success(newSubBrand):
      onSelect(newSubBrand, true)
      dismiss()
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("saving sub-brand failed: \(error.localizedDescription)")
    }
  }
}
