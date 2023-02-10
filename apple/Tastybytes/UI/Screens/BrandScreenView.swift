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
      ForEach(viewModel.brand.subBrands, id: \.self) { subBrand in
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
      }
    }
    .sheet(item: $viewModel.activeSheet) { sheet in
      NavigationStack {
        switch sheet {
        case .editBrand:
          if let editBrand = viewModel.editBrand {
            EditBrandSheetView(viewModel.client, brand: editBrand, brandOwner: viewModel.brand.brandOwner) {}
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
    case mergeProduct
  }

  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "BrandScreenView")
    let client: Client
    @Published var brand: Brand.JoinedSubBrandsProductsCompany
    @Published var showDeleteBrandConfirmationDialog = false

    @Published var companyJoined: Company.Joined?
    @Published var summary: Summary?
    @Published var activeSheet: Sheet?
    @Published var newCompanyNameSuggestion = ""
    @Published var editBrand: Brand.JoinedSubBrandsProductsCompany?
    @Published var productToMerge: Product.JoinedCategory? {
      didSet {
        setActiveSheet(.mergeProduct)
      }
    }

    @Published var productToDelete: Product.JoinedCategory? {
      didSet {
        if productToDelete != nil {
          showDeleteProductConfirmationDialog = true
        }
      }
    }

    @Published var showDeleteProductConfirmationDialog = false
    @Published var brandToDelete: Brand.JoinedSubBrandsProducts? {
      didSet {
        showDeleteBrandConfirmationDialog = true
      }
    }

    @Published var showDeleteCompanyConfirmationDialog = false

    init(_ client: Client, brand: Brand.JoinedSubBrandsProductsCompany) {
      self.client = client
      self.brand = brand
    }

    func setActiveSheet(_ sheet: Sheet) {
      activeSheet = sheet
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
  }
}
