import CachedAsyncImage
import SwiftUI

struct BrandScreenView: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var router: Router
  @StateObject private var viewModel: ViewModel

  init(brand: Brand.JoinedSubBrandsProducts) {
    _viewModel = StateObject(wrappedValue: ViewModel(brand: brand))
  }

  var body: some View {
    List {
      ForEach(viewModel.brand.subBrands, id: \.self) { subBrand in
        ForEach(subBrand.products, id: \.id) {
          product in
          NavigationLink(value: Route.product(Product
              .Joined(
                company: Company(id: 1, name: "test", logoUrl: nil, isVerified: false),
                product: product,
                subBrand: subBrand,
                brand: viewModel.brand
              ))) {
            HStack {
              Text(joinOptionalStrings([viewModel.brand.name, subBrand.name, product.name]))
                .lineLimit(nil)
              Spacer()
            }
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
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "BrandScreenView")
    @Published var brand: Brand.JoinedSubBrandsProducts
    @Published var showDeleteBrandConfirmationDialog = false

    init(brand: Brand.JoinedSubBrandsProducts) {
      self.brand = brand
    }

    func deleteBrand(onDelete: @escaping () -> Void) {
      Task {
        switch await repository.brand.delete(id: brand.id) {
        case .success:
          onDelete()
        case let .failure(error):
          print(error)
        }
      }
    }
  }
}
