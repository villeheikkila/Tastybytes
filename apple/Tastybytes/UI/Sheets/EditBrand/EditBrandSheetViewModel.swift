import PhotosUI
import SwiftUI

extension EditBrandSheet {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "EditBrandSheet")
    let client: Client
    @Published var name: String
    @Published var brandOwner: Company
    @Published var showToast = false
    @Published var initialBrandOwner: Company
    @Published var brand: Brand.JoinedSubBrandsProductsCompany
    @Published var selectedLogo: PhotosPickerItem? {
      didSet {
        if selectedLogo != nil {
          uploadLogo()
        }
      }
    }

    let onUpdate: () -> Void

    init(_ client: Client, brand: Brand.JoinedSubBrandsProductsCompany, onUpdate: @escaping () -> Void) {
      self.client = client
      self.brand = brand
      initialBrandOwner = brand.brandOwner
      brandOwner = brand.brandOwner
      name = brand.name
      self.onUpdate = onUpdate
    }

    func editBrand(
      onSuccess: @escaping () -> Void
    ) async {
      switch await client.brand
        .update(updateRequest: Brand.UpdateRequest(id: brand.id, name: name, brandOwnerId: brandOwner.id))
      {
      case .success:
        showToast.toggle()
        onSuccess()
      case let .failure(error):
        logger.error("failed to edit brand': \(error.localizedDescription)")
      }
    }

    func uploadLogo() {
      Task {
        guard let data = await selectedLogo?.getJPEG() else { return }
        switch await client.brand.uploadLogo(brandId: brand.id, data: data) {
        case .success:
          onUpdate()
        case let .failure(error):
          logger
            .error(
              "uplodaing company logo failed: \(error.localizedDescription)"
            )
        }
      }
    }
  }
}
