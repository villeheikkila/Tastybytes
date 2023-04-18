import PhotosUI
import SwiftUI

struct EditSubBrandSheet: View {
  private let logger = getLogger(category: "EditSubBrandSheet")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.dismiss) private var dismiss
  @State private var showMergeSubBrandsConfirmation = false
  @State private var newSubBrandName: String
  @State private var subBrand: SubBrand.JoinedProduct
  @State private var mergeTo: SubBrand.JoinedProduct? {
    didSet {
      if oldValue != nil {
        showMergeSubBrandsConfirmation = true
      } else {
        showMergeSubBrandsConfirmation = false
      }
    }
  }

  let onUpdate: () async -> Void
  let brand: Brand.JoinedSubBrandsProductsCompany

  init(
    brand: Brand.JoinedSubBrandsProductsCompany,
    subBrand: SubBrand.JoinedProduct,
    onUpdate: @escaping () async -> Void
  ) {
    self.brand = brand
    _subBrand = State(wrappedValue: subBrand)
    _newSubBrandName = State(wrappedValue: subBrand.name ?? "")
    self.onUpdate = onUpdate
  }

  var invalidNewName: Bool {
    !newSubBrandName.isValidLength(.normal) || subBrand
      .name == newSubBrandName
  }

  var body: some View {
    Form {
      Section("Name") {
        TextField("Name", text: $newSubBrandName)
        ProgressButton("Edit") {
          await editSubBrand(onSuccess: {
            await onUpdate()
          })
        }
        .disabled(invalidNewName)
      }

      if !brand.subBrands.contains(where: { $0.name != nil && $0.id != subBrand.id }) {
        Section("Merge to another sub-brand") {
          ForEach(brand.subBrands.filter { $0.name != nil && $0.id != subBrand.id }) { subBrand in
            if let name = subBrand.name {
              Button(name, action: { mergeTo = subBrand })
            }
          }
        }
      }
    }
    .navigationTitle("Edit \(subBrand.name.orEmpty)")
    .navigationBarItems(trailing: Button("Done", action: { dismiss() }).bold())
    .confirmationDialog("Are you sure you want to merge sub-brands? The merged sub-brand will be permanently deleted",
                        isPresented: $showMergeSubBrandsConfirmation,
                        titleVisibility: .visible,
                        presenting: mergeTo)
    { presenting in
      ProgressButton(
        "Merge \(subBrand.name ?? "default sub-brand") to \(presenting.name ?? "default sub-brand")",
        role: .destructive,
        action: {
          await mergeToSubBrand(subBrand: subBrand, onSuccess: {
            feedbackManager.trigger(.notification(.success))
            await onUpdate()
          })
        }
      )
    }
  }

  func mergeToSubBrand(subBrand: SubBrand.JoinedProduct, onSuccess: @escaping () async -> Void) async {
    guard let mergeTo else { return }
    switch await repository.subBrand
      .update(updateRequest: .brand(SubBrand.UpdateBrandRequest(id: subBrand.id, brandId: mergeTo.id)))
    {
    case .success:
      self.mergeTo = nil
      await onSuccess()
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to merge to merge sub-brand '\(subBrand.id)' to '\(mergeTo.id)': \(error.localizedDescription)")
    }
  }

  func editSubBrand(onSuccess: @escaping () async -> Void) async {
    switch await repository.subBrand
      .update(updateRequest: .name(SubBrand.UpdateNameRequest(id: subBrand.id, name: newSubBrandName)))
    {
    case .success:
      feedbackManager.toggle(.success("Sub-brand updated!"))
      await onSuccess()
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to edit sub-brand': \(error.localizedDescription)")
    }
  }
}
