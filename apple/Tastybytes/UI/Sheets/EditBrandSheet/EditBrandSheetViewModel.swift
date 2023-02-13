import SwiftUI

extension EditBrandSheetView {
  enum Sheet: Identifiable {
    var id: Self { self }
    case brandOwner
  }

  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "EditBrandSheetView")
    let client: Client
    @Published var activeSheet: Sheet?
    @Published var name: String
    @Published var brandOwner: Company
    @Published var showToast = false
    @Published var initialBrandOwner: Company
    @Published var brand: Brand.JoinedSubBrandsProductsCompany

    init(_ client: Client, brand: Brand.JoinedSubBrandsProductsCompany) {
      self.client = client
      self.brand = brand
      initialBrandOwner = brand.brandOwner
      brandOwner = brand.brandOwner
      name = brand.name
    }

    func editBrand(
      onSuccess: @escaping () -> Void
    ) {
      Task {
        switch await client.brand
          .update(updateRequest: Brand.UpdateRequest(id: brand.id, name: name, brandOwnerId: brandOwner.id))
        {
        case .success:
          showToast.toggle()
          onSuccess()
        case let .failure(error):
          logger.error("failed to edit brand '\(self.brand.id)': \(error.localizedDescription)")
        }
      }
    }
  }
}
