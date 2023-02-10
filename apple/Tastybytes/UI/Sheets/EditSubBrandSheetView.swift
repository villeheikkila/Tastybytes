import AlertToast
import SwiftUI

struct EditSubBrandSheetView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: ViewModel
  @State private var newSubBrandName: String

  let brand: Brand.JoinedSubBrandsProductsCompany
  let subBrand: SubBrand.JoinedProduct
  let onUpdate: () -> Void

  init(
    _ client: Client,
    brand: Brand.JoinedSubBrandsProductsCompany,
    subBrand: SubBrand.JoinedProduct,
    onUpdate: @escaping () -> Void
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
    self.brand = brand
    self.subBrand = subBrand
    self.onUpdate = onUpdate
    _newSubBrandName = State(initialValue: subBrand.name.orEmpty)
  }

  var body: some View {
    List {
      Section {
        TextField("Name", text: $newSubBrandName)
        Button("Edit") {
          viewModel.editSubBrand(subBrand: subBrand, name: newSubBrandName, onSuccess: {
            onUpdate()
          })
        }
        .disabled(!validateStringLength(str: newSubBrandName, type: .normal) || subBrand.name == newSubBrandName)
      } header: {
        Text("Name")
      }

      if !brand.subBrands.filter { $0.name != nil && $0.id != subBrand.id }.isEmpty {
        Section {
          ForEach(brand.subBrands.filter { $0.name != nil && $0.id != subBrand.id }, id: \.self) { subBrand in
            Button(action: {
              viewModel.mergeTo = subBrand
            }) {
              if let name = subBrand.name {
                Text(name)
              }
            }
          }
        } header: {
          Text("Merge to another sub-brand")
        }
      }
    }
    .navigationTitle("Edit \(subBrand.name.orEmpty)")
    .navigationBarItems(trailing: Button(action: {
      dismiss()
    }) {
      Text("Done").bold()
    })
    .toast(isPresenting: $viewModel.showToast, duration: 2, tapToDismiss: true) {
      AlertToast(type: .complete(.green), title: "Sub-brand updated!")
    }
    .confirmationDialog("Merge Sub-brands Confirmation",
                        isPresented: $viewModel.showMergeSubBrandsConfirmation,
                        presenting: viewModel.mergeTo) { presenting in
      Button(
        "Merge \(subBrand.name.orEmpty) to \(presenting.name ?? "default sub-brand")",
        role: .destructive,
        action: {
          viewModel.mergeToSubBrand(subBrand: subBrand, onSuccess: {
            onUpdate()
          })
        }
      )
    }
  }
}

extension EditSubBrandSheetView {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "EditSubBrandSheetView")
    let client: Client
    @Published var showToast = false
    @Published var showMergeSubBrandsConfirmation = false
    @Published var mergeTo: SubBrand.JoinedProduct? {
      didSet {
        if oldValue != nil {
          showMergeSubBrandsConfirmation = true
        } else {
          showMergeSubBrandsConfirmation = false
        }
      }
    }

    init(_ client: Client) {
      self.client = client
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

    func editSubBrand(subBrand: SubBrand.JoinedProduct, name: String, onSuccess: @escaping () -> Void) {
      Task {
        switch await client.subBrand
          .update(updateRequest: .name(SubBrand.UpdateNameRequest(id: subBrand.id, name: name)))
        {
        case .success:
          showToast.toggle()
          onSuccess()
        case let .failure(error):
          logger.error("failed to edit sub-brand '\(subBrand.id)' to '\(name)': \(error.localizedDescription)")
        }
      }
    }
  }
}
