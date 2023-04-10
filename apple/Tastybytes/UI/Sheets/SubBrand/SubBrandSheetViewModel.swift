import SwiftUI

extension SubBrandSheet {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "SubBrandSheet")
    let client: Client
    let brandWithSubBrands: Brand.JoinedSubBrands
    @Published var subBrandName = ""

    init(_ client: Client, brandWithSubBrands: Brand.JoinedSubBrands) {
      self.client = client
      self.brandWithSubBrands = brandWithSubBrands
    }

    var filteredSubBrands: [SubBrand] {
      brandWithSubBrands.subBrands.filter { $0.name != nil }
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
}
