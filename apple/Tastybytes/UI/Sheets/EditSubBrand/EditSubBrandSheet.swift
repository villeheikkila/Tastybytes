import AlertToast
import PhotosUI
import SwiftUI

struct EditSubBrandSheet: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var hapticManager: HapticManager
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager

  let onUpdate: () async -> Void

  init(
    _ client: Client,
    brand: Brand.JoinedSubBrandsProductsCompany,
    subBrand: SubBrand.JoinedProduct,
    onUpdate: @escaping () async -> Void
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, subBrand: subBrand, brand: brand))
    self.onUpdate = onUpdate
  }

  var body: some View {
    Form {
      Section {
        TextField("Name", text: $viewModel.newSubBrandName)
        ProgressButton("Edit") {
          await viewModel.editSubBrand(onSuccess: {
            await onUpdate()
          })
        }
        .disabled(viewModel.invalidNewName)
      } header: {
        Text("Name")
      }

      if !viewModel.brand.subBrands.contains(where: { $0.name != nil && $0.id != viewModel.subBrand.id }) {
        Section {
          ForEach(viewModel.brand.subBrands.filter { $0.name != nil && $0.id != viewModel.subBrand.id }) { subBrand in
            if let name = subBrand.name {
              Button(name, action: { viewModel.mergeTo = subBrand })
            }
          }
        } header: {
          Text("Merge to another sub-brand")
        }
      }
    }
    .navigationTitle("Edit \(viewModel.subBrand.name.orEmpty)")
    .navigationBarItems(trailing: Button("Done", action: { dismiss() }).bold())
    .toast(isPresenting: $viewModel.showToast, duration: 2, tapToDismiss: true) {
      AlertToast(type: .complete(.green), title: "Sub-brand updated!")
    }
    .confirmationDialog("Are you sure you want to merge sub-brands? The merged sub-brand will be permanently deleted",
                        isPresented: $viewModel.showMergeSubBrandsConfirmation,
                        titleVisibility: .visible,
                        presenting: viewModel.mergeTo)
    { presenting in
      ProgressButton(
        "Merge \(viewModel.subBrand.name.orEmpty) to \(presenting.name ?? "default sub-brand")",
        role: .destructive,
        action: {
          await viewModel.mergeToSubBrand(subBrand: viewModel.subBrand, onSuccess: {
            hapticManager.trigger(.notification(.success))
            await onUpdate()
          })
        }
      )
    }
  }
}
