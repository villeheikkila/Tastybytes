import SwiftUI

extension EditSubBrandSheet {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "EditSubBrandSheet")
    let client: Client
    @Published var showToast = false
    @Published var showMergeSubBrandsConfirmation = false
    @Published var newSubBrandName: String
    @Published var brand: Brand.JoinedSubBrandsProductsCompany
    @Published var subBrand: SubBrand.JoinedProduct

    @Published var mergeTo: SubBrand.JoinedProduct? {
      didSet {
        if oldValue != nil {
          showMergeSubBrandsConfirmation = true
        } else {
          showMergeSubBrandsConfirmation = false
        }
      }
    }

    init(_ client: Client, subBrand: SubBrand.JoinedProduct, brand: Brand.JoinedSubBrandsProductsCompany) {
      self.client = client
      self.brand = brand
      self.subBrand = subBrand
      newSubBrandName = subBrand.name ?? ""
    }

    var invalidNewName: Bool {
      !validateStringLength(str: newSubBrandName, type: .normal) || subBrand
        .name == newSubBrandName
    }

    func mergeToSubBrand(subBrand: SubBrand.JoinedProduct, onSuccess: @escaping () -> Void) {
      if let mergeTo {
        Task {
          switch await client.subBrand
            .update(updateRequest: .brand(SubBrand.UpdateBrandRequest(id: subBrand.id, brandId: mergeTo.id)))
          {
          case .success:
            self.mergeTo = nil
            onSuccess()
          case let .failure(error):
            logger
              .error(
                "failed to merge to merge sub-brand '\(subBrand.id)' to '\(mergeTo.id)': \(error.localizedDescription)"
              )
          }
        }
      }
    }

    func editSubBrand(onSuccess: @escaping () -> Void) {
      Task {
        switch await client.subBrand
          .update(updateRequest: .name(SubBrand.UpdateNameRequest(id: subBrand.id, name: newSubBrandName)))
        {
        case .success:
          showToast.toggle()
          onSuccess()
        case let .failure(error):
          logger
            .error(
              """
              failed to edit sub-brand '\(self.subBrand.id)' to '\(self.newSubBrandName)': \(error.localizedDescription)
              """
            )
        }
      }
    }
  }
}
