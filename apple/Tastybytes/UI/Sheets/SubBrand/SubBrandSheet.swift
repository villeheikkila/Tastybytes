import SwiftUI

struct SubBrandSheet: View {
  private let logger = getLogger(category: "SubBrandSheet")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @Environment(\.dismiss) private var dismiss
  @State private var subBrandName = ""
  @State private var searchText: String = ""
  @Binding var subBrand: SubBrandProtocol?

  let brandWithSubBrands: Brand.JoinedSubBrands

  var filteredSubBrands: [SubBrand] {
    brandWithSubBrands.subBrands.sorted()
      .filter { sub in
        guard let name = sub.name else { return false }
        return searchText.isEmpty || name.contains(searchText) == true
      }
  }

  var body: some View {
    List {
      ForEach(filteredSubBrands) { subBrand in
        if let name = subBrand.name {
          Button(name, action: {
            self.subBrand = subBrand
            dismiss()
          })
        }
      }

      if profileManager.hasPermission(.canCreateBrands) {
        Section("Add new sub-brand for \(brandWithSubBrands.name)") {
          TextField("Name", text: $subBrandName)
            .overlay(
              ScanTextButton(text: $subBrandName)
                .padding(.trailing, 6),
              alignment: .trailing
            )
          ProgressButton("Create") { await createNewSubBrand() }
            .disabled(!subBrandName.isValidLength(.normal))
        }
      }
    }
    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
    .navigationTitle("Sub-brands")
    .navigationBarItems(trailing: Button("Cancel", role: .cancel, action: { dismiss() }).bold())
  }

  func createNewSubBrand() async {
    switch await repository.subBrand
      .insert(newSubBrand: SubBrand.NewRequest(name: subBrandName, brandId: brandWithSubBrands.id))
    {
    case let .success(newSubBrand):
      feedbackManager.toggle(.success("New Sub-brand Created!"))
      subBrand = newSubBrand
      dismiss()
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("saving sub-brand failed: \(error.localizedDescription)")
    }
  }
}
