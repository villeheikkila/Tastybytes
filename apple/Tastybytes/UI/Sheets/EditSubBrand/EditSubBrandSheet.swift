import AlertToast
import PhotosUI
import SwiftUI

struct EditSubBrandSheet: View {
  private let logger = getLogger(category: "EditSubBrandSheet")
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var profileManager: ProfileManager
  @State private var showToast = false
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

  let client: Client
  let onUpdate: () async -> Void
  let brand: Brand.JoinedSubBrandsProductsCompany

  init(
    _ client: Client,
    brand: Brand.JoinedSubBrandsProductsCompany,
    subBrand: SubBrand.JoinedProduct,
    onUpdate: @escaping () async -> Void
  ) {
    self.client = client
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
      Section {
        TextField("Name", text: $newSubBrandName)
        ProgressButton("Edit") {
          await editSubBrand(onSuccess: {
            await onUpdate()
          })
        }
        .disabled(invalidNewName)
      } header: {
        Text("Name")
      }

      if !brand.subBrands.contains(where: { $0.name != nil && $0.id != subBrand.id }) {
        Section {
          ForEach(brand.subBrands.filter { $0.name != nil && $0.id != subBrand.id }) { subBrand in
            if let name = subBrand.name {
              Button(name, action: { mergeTo = subBrand })
            }
          }
        } header: {
          Text("Merge to another sub-brand")
        }
      }
    }
    .navigationTitle("Edit \(subBrand.name.orEmpty)")
    .navigationBarItems(trailing: Button("Done", action: { dismiss() }).bold())
    .toast(isPresenting: $showToast, duration: 2, tapToDismiss: true) {
      AlertToast(type: .complete(.green), title: "Sub-brand updated!")
    }
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
            hapticManager.trigger(.notification(.success))
            await onUpdate()
          })
        }
      )
    }
  }

  func mergeToSubBrand(subBrand: SubBrand.JoinedProduct, onSuccess: @escaping () async -> Void) async {
    guard let mergeTo else { return }
    switch await client.subBrand
      .update(updateRequest: .brand(SubBrand.UpdateBrandRequest(id: subBrand.id, brandId: mergeTo.id)))
    {
    case .success:
      self.mergeTo = nil
      await onSuccess()
    case let .failure(error):
      logger.error("failed to merge to merge sub-brand '\(subBrand.id)' to '\(mergeTo.id)': \(error.localizedDescription)")
    }
  }

  func editSubBrand(onSuccess: @escaping () async -> Void) async {
    switch await client.subBrand
      .update(updateRequest: .name(SubBrand.UpdateNameRequest(id: subBrand.id, name: newSubBrandName)))
    {
    case .success:
      showToast.toggle()
      await onSuccess()
    case let .failure(error):
      logger.error("failed to edit sub-brand': \(error.localizedDescription)")
    }
  }
}
