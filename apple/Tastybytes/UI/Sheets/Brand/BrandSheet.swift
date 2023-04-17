import SwiftUI

struct BrandSheet: View {
  private let logger = getLogger(category: "BrandSheet")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @Environment(\.dismiss) private var dismiss
  @State private var brandsWithSubBrands = [Brand.JoinedSubBrands]()
  @State private var brandName = ""

  let brandOwner: Company
  let mode: Mode
  let onSelect: (_ company: Brand.JoinedSubBrands, _ createdNew: Bool) -> Void

  var body: some View {
    List {
      if mode == .select {
        ForEach(brandsWithSubBrands) { brand in
          Button(brand.name, action: {
            onSelect(brand, false)
            dismiss()
          })
        }
      }

      if profileManager.hasPermission(.canCreateBrands) {
        Section("Add new brand for \(brandOwner.name)") {
          TextField("Name", text: $brandName)
          ProgressButton("Create") {
            await createNewBrand(brandOwner) { brand in
              onSelect(brand, true)
              dismiss()
            }
          }
          .disabled(!brandName.isValidLength(.normal))
        }
      }
    }
    .navigationTitle("\(mode == .select ? "Select" : "Add") brand")
    .navigationBarItems(trailing: Button("Cancel", role: .cancel, action: { dismiss() }).bold())
    .task {
      await loadBrands(brandOwner)
    }
  }

  func loadBrands(_ brandOwner: Company) async {
    switch await repository.brand.getByBrandOwnerId(brandOwnerId: brandOwner.id) {
    case let .success(brandsWithSubBrands):
      self.brandsWithSubBrands = brandsWithSubBrands
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to load brands for \(brandOwner.id): \(error.localizedDescription)")
    }
  }

  func createNewBrand(_ brandOwner: Company, _ onCreation: @escaping (_ brand: Brand.JoinedSubBrands) -> Void) async {
    switch await repository.brand.insert(newBrand: Brand.NewRequest(name: brandName, brandOwnerId: brandOwner.id)) {
    case let .success(brandWithSubBrands):
      onCreation(brandWithSubBrands)
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to create new brand for \(brandOwner.id): \(error.localizedDescription)")
    }
  }
}

extension BrandSheet {
  enum Mode {
    case select, new
  }
}
