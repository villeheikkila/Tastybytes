import AlertToast
import SwiftUI

struct EditBrandSheetView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: ViewModel
  @State private var name: String
  @State private var brandOwner: Company
  @State private var editSubBrand: SubBrand.JoinedProduct?
  @State private var showToast = false

  let initialBrandOwner: Company
  let brand: Brand.JoinedSubBrandsProductsCompany
  let onUpdate: () -> Void

  init(
    _ client: Client,
    brand: Brand.JoinedSubBrandsProductsCompany,
    brandOwner: Company,
    onUpdate: @escaping () -> Void
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
    self.brand = brand
    initialBrandOwner = brandOwner
    _brandOwner = State(initialValue: brandOwner)
    _name = State(initialValue: brand.name)
    self.onUpdate = onUpdate
  }

  var body: some View {
    Form {
      Section {
        TextField("Name", text: $name)
        Button("Edit") {
          viewModel.editBrand(brand: brand, name: name, brandOwner: brandOwner) {
            onUpdate()
            showToast.toggle()
          }
        }.disabled(!validateStringLength(str: name, type: .normal) || brand.name == name)
      } header: {
        Text("Brand name")
      }

      Section {
        Button(action: {
          viewModel.activeSheet = Sheet.brandOwner
        }) {
          Text(brandOwner.name)
        }
        Button("Change brand owner") {
          viewModel.editBrand(brand: brand, name: name, brandOwner: brandOwner) {
            onUpdate()
            showToast.toggle()
          }
        }.disabled(brandOwner.id == initialBrandOwner.id)
      } header: {
        Text("Brand Owner")
      }

      Section {
        ForEach(brand.subBrands, id: \.id) { subBrand in
          if let subBrandName = subBrand.name {
            HStack {
              Text(subBrandName)
              Spacer()
              Menu {
                Button(action: {
                  editSubBrand = subBrand
                  viewModel.activeSheet = Sheet.editSubBrand
                }) {
                  Label("Edit", systemImage: "pencil")
                }

                Button(action: {
                  viewModel.toDeleteSubBrand = subBrand
                }) {
                  Label("Delete", systemImage: "trash")
                    .disabled(subBrand.isVerified)
                }
              } label: {
                Image(systemName: "ellipsis")
              }
            }
          }
        }
      } header: {
        Text("Sub-brands")
      }
    }
    .navigationTitle("Edit Brand")
    .navigationBarItems(trailing: Button(action: {
      dismiss()
    }) {
      Text("Done").bold()
    })
    .sheet(item: $viewModel.activeSheet) { sheet in NavigationStack {
      switch sheet {
      case .brandOwner:
        CompanySheetView(viewModel.client, onSelect: { company, _ in
          brandOwner = company
          viewModel.activeSheet = nil
        })
      case .editSubBrand:
        if let subBrand = editSubBrand {
          EditSubBrandSheetView(viewModel.client, brand: brand, subBrand: subBrand,
                                onUpdate: {
                                  onUpdate()
                                },
                                onClose: {
                                  viewModel.activeSheet = nil
                                  editSubBrand = nil
                                })
        }
      }
    }
    }
    .toast(isPresenting: $showToast, duration: 2, tapToDismiss: true) {
      AlertToast(type: .complete(.green), title: "Brand updated!")
    }
    .confirmationDialog("Delete Sub-brand",
                        isPresented: $viewModel.showDeleteSubBrandConfirmation,
                        presenting: viewModel.toDeleteSubBrand) { presenting in
      Button("Delete \(presenting.name.orEmpty) and all related products", role: .destructive, action: {
        viewModel.deleteSubBrand(onSuccess: {
          onUpdate()
        })
      })
    }
  }
}

extension EditBrandSheetView {
  enum Sheet: Identifiable {
    var id: Self { self }
    case brandOwner
    case editSubBrand
  }

  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "EditBrandSheetView")
    let client: Client
    @Published var activeSheet: Sheet?
    @Published var showDeleteSubBrandConfirmation = false
    @Published var toDeleteSubBrand: SubBrand.JoinedProduct? {
      didSet {
        if oldValue == nil {
          showDeleteSubBrandConfirmation = true
        } else {
          showDeleteSubBrandConfirmation = false
        }
      }
    }

    init(_ client: Client) {
      self.client = client
    }

    func editBrand(
      brand: Brand.JoinedSubBrandsProductsCompany,
      name: String,
      brandOwner: Company,
      onSuccess: @escaping () -> Void
    ) {
      Task {
        switch await client.brand
          .update(updateRequest: Brand.UpdateRequest(id: brand.id, name: name, brandOwnerId: brandOwner.id))
        {
        case .success:
          onSuccess()
        case let .failure(error):
          logger.error("failed to edit brand '\(brand.id)': \(error.localizedDescription)")
        }
      }
    }

    func deleteSubBrand(onSuccess: @escaping () -> Void) {
      if let toDeleteSubBrand {
        Task {
          switch await client.subBrand.delete(id: toDeleteSubBrand.id) {
          case .success:
            onSuccess()
          case let .failure(error):
            logger.error("failed to delete brand '\(toDeleteSubBrand.id)': \(error.localizedDescription)")
          }
        }
      }
    }
  }
}

struct EditSubBrandSheetView: View {
  @StateObject private var viewModel: ViewModel
  @State private var newSubBrandName: String

  let brand: Brand.JoinedSubBrandsProductsCompany
  let subBrand: SubBrand.JoinedProduct
  let onUpdate: () -> Void
  let onClose: () -> Void

  init(
    _ client: Client,
    brand: Brand.JoinedSubBrandsProductsCompany,
    subBrand: SubBrand.JoinedProduct,
    onUpdate: @escaping () -> Void,
    onClose: @escaping () -> Void
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
    self.brand = brand
    self.subBrand = subBrand
    self.onUpdate = onUpdate
    self.onClose = onClose
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
      onClose()
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
