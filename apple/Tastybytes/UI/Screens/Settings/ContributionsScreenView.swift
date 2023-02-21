import SwiftUI

struct ContributionsScreenView: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

  var body: some View {
    List {
      Button(action: {
        viewModel.activeSheet = .products
      }) {
        HStack {
          Text("Products")
          Spacer()
          Text(String(viewModel.products.count))
        }
      }
    }
    .navigationTitle("Your Contributions")
    .navigationBarTitleDisplayMode(.inline)
    .sheet(item: $viewModel.activeSheet) { sheet in
      NavigationStack {
        switch sheet {
        case .products:
          DismissableSheet(title: "Products") {
            contributedProductsSheet
          }
        }
      }
    }
    .task {
      viewModel.loadContributions(userId: profileManager.getId())
    }
  }

  private var contributedProductsSheet: some View {
    List {
      ForEach(viewModel.products, id: \.id) { product in
        ProductItemView(product: product)
      }
    }
  }
}

extension ContributionsScreenView {
  enum Sheet: Identifiable {
    var id: Self { self }

    case products
  }

  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ContributionsScreenView")
    let client: Client
    @Published var products: [Product.Joined] = []
    @Published var activeSheet: Sheet?

    init(_ client: Client) {
      self.client = client
    }

    func loadContributions(userId: UUID) {
      Task {
        switch await client.product.getCreatedByUserId(id: userId) {
        case let .success(products):
          withAnimation {
            self.products = products
          }
        case let .failure(error):
          logger.warning("failed to load blocked users: \(error.localizedDescription)")
        }
      }
    }
  }
}
