import SwiftUI

struct ProductVerificationScreen: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var router: Router

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

  var body: some View {
    List {
      ForEach(viewModel.products, id: \.id) { product in
        ProductItemView(product: product)
          .contentShape(Rectangle())
          .accessibilityAddTraits(.isLink)
          .onTapGesture {
            router.navigate(to: .product(product), resetStack: false)
          }
      }
    }
    .navigationBarTitle("Unverified Products")
    .refreshable {
      await viewModel.loadProducts()
    }
    .task {
      await viewModel.loadProducts()
    }
  }
}

extension ProductVerificationScreen {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "FlavorManagementView")
    let client: Client
    @Published var products = [Product.Joined]()

    init(_ client: Client) {
      self.client = client
    }

    func loadProducts() async {
      switch await client.product.getFeed(.topRated, from: 0, to: 100, categoryFilterId: nil) {
      case let .success(products):
        withAnimation {
          self.products = products
        }
      case let .failure(error):
        logger
          .error(
            "fetching flavors failed: \(error.localizedDescription)"
          )
      }
    }
  }
}
