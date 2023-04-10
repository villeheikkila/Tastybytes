import AlertToast
import PhotosUI
import SwiftUI

struct EditSubBrandSheet: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var hapticManager: HapticManager
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager

  let onUpdate: () -> Void

  init(
    _ client: Client,
    brand: Brand.JoinedSubBrandsProductsCompany,
    subBrand: SubBrand.JoinedProduct,
    onUpdate: @escaping () -> Void
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, subBrand: subBrand, brand: brand))
    self.onUpdate = onUpdate
  }

  var body: some View {
    Form {
      Section {
        TextField("Name", text: $viewModel.newSubBrandName)
        Button("Edit") {
          viewModel.editSubBrand(onSuccess: {
            onUpdate()
          })
        }
        .disabled(viewModel.invalidNewName)
      } header: {
        Text("Name")
      }

      if !viewModel.brand.subBrands.contains(where: { $0.name != nil && $0.id != viewModel.subBrand.id }) {
        Section {
          ForEach(viewModel.brand.subBrands.filter { $0.name != nil && $0.id != viewModel.subBrand.id }) { subBrand in
            Button(action: { viewModel.mergeTo = subBrand }, label: {
              if let name = subBrand.name {
                Text(name)
              }
            })
          }
        } header: {
          Text("Merge to another sub-brand")
        }
      }
    }
    .navigationTitle("Edit \(viewModel.subBrand.name.orEmpty)")
    .navigationBarItems(trailing: Button(action: { dismiss() }, label: {
      Text("Done").bold()
    }))
    .toast(isPresenting: $viewModel.showToast, duration: 2, tapToDismiss: true) {
      AlertToast(type: .complete(.green), title: "Sub-brand updated!")
    }
    .confirmationDialog("Are you sure you want to merge sub-brands? The merged sub-brand will be permanently deleted",
                        isPresented: $viewModel.showMergeSubBrandsConfirmation,
                        titleVisibility: .visible,
                        presenting: viewModel.mergeTo)
    { presenting in
      Button(
        "Merge \(viewModel.subBrand.name.orEmpty) to \(presenting.name ?? "default sub-brand")",
        role: .destructive,
        action: {
          viewModel.mergeToSubBrand(subBrand: viewModel.subBrand, onSuccess: {
            hapticManager.trigger(.notification(.success))
            onUpdate()
          })
        }
      )
    }
  }
}
