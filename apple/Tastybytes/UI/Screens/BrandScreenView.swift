import CachedAsyncImage
import SwiftUI

struct BrandScreenView: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var router: Router
  @StateObject private var viewModel: ViewModel

  init(_ client: Client, brand: Brand.JoinedSubBrandsProductsCompany) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, brand: brand))
  }

  var body: some View {
    List {
      ForEach(viewModel.brand.subBrands.sorted { lhs, rhs -> Bool in
        switch (lhs.name, rhs.name) {
        case let (lhs?, rhs?): return lhs < rhs
        case (nil, _): return true
        case (_?, nil): return false
        }
      }, id: \.self) { subBrand in
        Section {
          ForEach(subBrand.products, id: \.id) {
            product in
            NavigationLink(value: Route.product(Product
                .Joined(
                  product: product,
                  subBrand: subBrand,
                  brand: viewModel.brand
                ))) {
              HStack {
                Text(joinOptionalStrings([viewModel.brand.name, subBrand.name, product.name]))
                  .lineLimit(nil)
                Spacer()
              }
              .contextMenu {
                if profileManager.hasPermission(.canMergeProducts) {
                  Button(action: {
                    viewModel.productToMerge = product
                  }) {
                    Text("Merge product to...")
                  }
                }

                if profileManager.hasPermission(.canDeleteProducts) {
                  Button(action: {
                    viewModel.productToDelete = product
                  }) {
                    Label("Delete", systemImage: "trash.fill")
                      .foregroundColor(.red)
                  }
                  .disabled(product.isVerified)
                }
                Spacer()
              }
            }
          }
        } header: {
          HStack {
            if let name = subBrand.name {
              Text(name)
            }

            Spacer()
            Menu {
              if profileManager.hasPermission(.canEditBrands) {
                Button(action: {
                  viewModel.editSubBrand = subBrand
                }) {
                  Label("Edit", systemImage: "pencil")
                }
              }

              if subBrand.isVerified {
                Label("Verified", systemImage: "checkmark.circle")
              } else if profileManager.hasPermission(.canVerify) {
                Button(action: {
                  viewModel.verifySubBrand(subBrand)
                }) {
                  Label("Verify", systemImage: "checkmark")
                }
              } else {
                Label("Not verified", systemImage: "x.circle")
              }

              if profileManager.hasPermission(.canDeleteBrands) {
                Button(action: {
                  viewModel.toDeleteSubBrand = subBrand
                }) {
                  Label("Delete", systemImage: "trash.fill")
                }
                .disabled(subBrand.isVerified)
              }
            } label: {
              Image(systemName: "ellipsis")
                .frame(width: 24, height: 24)
            }
          }
        }
        .headerProminence(.increased)
      }
    }
    .sheet(item: $viewModel.activeSheet) { sheet in
      NavigationStack {
        switch sheet {
        case .editBrand:
          EditBrandSheetView(viewModel.client, brand: viewModel.brand) {
            viewModel.refresh()
          }
        case .editSubBrand:
          if let editSubBrand = viewModel.editSubBrand {
            EditSubBrandSheetView(viewModel.client, brand: viewModel.brand, subBrand: editSubBrand) {
              viewModel.refresh()
            }
          }
        case .mergeProduct:
          if let productToMerge = viewModel.productToMerge {
            MergeSheetView(viewModel.client, productToMerge: productToMerge)
          }
        }
      }
    }
    .navigationTitle(viewModel.brand.name)
    .navigationBarItems(trailing: navigationBarMenu)
    .confirmationDialog("Delete Sub-brand",
                        isPresented: $viewModel.showDeleteSubBrandConfirmation,
                        presenting: viewModel.toDeleteSubBrand) { presenting in
      Button("Delete \(presenting.name.orEmpty) and all related products", role: .destructive, action: {
        viewModel.deleteSubBrand()
      })
    }
    .confirmationDialog("Delete Brand Confirmation",
                        isPresented: $viewModel.showDeleteBrandConfirmationDialog,
                        presenting: viewModel.brand) { presenting in
      Button("Delete \(presenting.name) Brand", role: .destructive, action: {
        viewModel.deleteBrand(onDelete: {
          router.reset()
        })
      })
    }
  }

  private var navigationBarMenu: some View {
    Menu {
      ShareLink("Share", item: NavigatablePath.brand(id: viewModel.brand.id).url)

      Divider()

      if profileManager.hasPermission(.canEditBrands) {
        Button(action: {
          viewModel.setActiveSheet(.editBrand)
        }) {
          Label("Edit", systemImage: "pencil")
        }
      }

      if viewModel.brand.isVerified {
        Label("Verified", systemImage: "checkmark.circle")
      } else if profileManager.hasPermission(.canVerify) {
        Button(action: {
          viewModel.verifyBrand()
        }) {
          Label("Verify", systemImage: "checkmark")
        }
      } else {
        Label("Not verified", systemImage: "x.circle")
      }

      if profileManager.hasPermission(.canDeleteBrands) {
        Button(action: {
          viewModel.showDeleteBrandConfirmationDialog.toggle()
        }) {
          Label("Delete", systemImage: "trash.fill")
        }
        .disabled(viewModel.brand.isVerified)
      }
    } label: {
      Image(systemName: "ellipsis")
    }
  }
}

extension BrandScreenView {
  enum Sheet: Identifiable {
    var id: Self { self }
    case editBrand
    case editSubBrand
    case mergeProduct
  }

  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "BrandScreenView")
    let client: Client
    @Published var brand: Brand.JoinedSubBrandsProductsCompany
    @Published var summary: Summary?
    @Published var activeSheet: Sheet?
    @Published var editBrand: Brand.JoinedSubBrandsProductsCompany?
    @Published var editSubBrand: SubBrand.JoinedProduct? {
      didSet {
        setActiveSheet(.editSubBrand)
      }
    }

    @Published var productToMerge: Product.JoinedCategory? {
      didSet {
        setActiveSheet(.mergeProduct)
      }
    }

    @Published var showDeleteProductConfirmationDialog = false
    @Published var productToDelete: Product.JoinedCategory? {
      didSet {
        if productToDelete != nil {
          showDeleteProductConfirmationDialog = true
        }
      }
    }

    @Published var showDeleteBrandConfirmationDialog = false
    @Published var brandToDelete: Brand.JoinedSubBrandsProducts? {
      didSet {
        showDeleteBrandConfirmationDialog = true
      }
    }

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

    init(_ client: Client, brand: Brand.JoinedSubBrandsProductsCompany) {
      self.client = client
      self.brand = brand
    }

    func setActiveSheet(_ sheet: Sheet) {
      activeSheet = sheet
    }

    func refresh() {}

    func verifyBrand() {
      Task {
        switch await client.brand.verify(id: brand.id) {
        case .success:
          brand = Brand.JoinedSubBrandsProductsCompany(
            id: brand.id,
            name: brand.name,
            isVerified: true,
            brandOwner: brand.brandOwner,
            subBrands: brand.subBrands
          )
        case let .failure(error):
          logger
            .error("failed to verify brand by id '\(self.brand.id)': \(error.localizedDescription)")
        }
      }
    }

    func verifySubBrand(_ subBrand: SubBrand.JoinedProduct) {
      Task {
        switch await client.subBrand.verify(id: subBrand.id) {
        case .success:
          logger
            .info("sub-brand succesfully verified")
        case let .failure(error):
          logger
            .error("failed to verify brand by id '\(self.brand.id)': \(error.localizedDescription)")
        }
      }
    }

    func deleteBrand(onDelete: @escaping () -> Void) {
      Task {
        switch await client.brand.delete(id: brand.id) {
        case .success:
          onDelete()
        case let .failure(error):
          logger
            .error("failed to delete brand by id '\(self.brand.id)': \(error.localizedDescription)")
        }
      }
    }

    func deleteSubBrand() {
      if let toDeleteSubBrand {
        Task {
          switch await client.subBrand.delete(id: toDeleteSubBrand.id) {
          case .success:
            logger.info("succesfully deleted sub-brand")
          case let .failure(error):
            logger.error("failed to delete brand '\(toDeleteSubBrand.id)': \(error.localizedDescription)")
          }
        }
      }
    }
  }
}
