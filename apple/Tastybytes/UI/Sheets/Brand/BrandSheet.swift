import SwiftUI

struct BrandSheet: View {
  private let logger = getLogger(category: "BrandSheet")
  @Environment(Repository.self) private var repository
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var router: Router
  @Environment(\.dismiss) private var dismiss
  @State private var brandsWithSubBrands = [Brand.JoinedSubBrands]()
  @State private var brandName = ""
  @State private var searchText: String = ""
  @Binding var brand: Brand.JoinedSubBrands?

  let brandOwner: Company
  let mode: Mode

  var filteredBrands: [Brand.JoinedSubBrands] {
    brandsWithSubBrands.filter { searchText.isEmpty || $0.name.contains(searchText) == true }
  }

  var body: some View {
    List {
      if mode == .select {
        ForEach(filteredBrands) { brand in
          Button(brand.name, action: {
            self.brand = brand
            dismiss()
          })
        }
      }

      if profileManager.hasPermission(.canCreateBrands) {
        Section("Add new brand for \(brandOwner.name)") {
          TextField("Name", text: $brandName)
            .overlay(
              ScanTextButton(text: $brandName),
              alignment: .trailing
            )
          ProgressButton("Create") {
            await createNewBrand()
          }
          .disabled(!brandName.isValidLength(.normal))
        }
      }
    }
    .navigationTitle("\(mode == .select ? "Select" : "Add") brand")
    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
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
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to load brands for \(brandOwner.id): \(error.localizedDescription)")
    }
  }

  func createNewBrand() async {
    switch await repository.brand.insert(newBrand: Brand.NewRequest(name: brandName, brandOwnerId: brandOwner.id)) {
    case let .success(brandWithSubBrands):
      feedbackManager.toggle(.success("New Brand Created!"))
      if mode == .new {
        router.fetchAndNavigateTo(repository, .brand(id: brandWithSubBrands.id))
      }
      brand = brandWithSubBrands
      dismiss()
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
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
