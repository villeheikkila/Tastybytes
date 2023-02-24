import SwiftUI

struct ProductFeedScreen: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var router: Router

  init(_ client: Client, feed: ProductFeedType) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, feed: feed))
  }

  var body: some View {
    List {
      ForEach(viewModel.products.unique(selector: { $0.id == $1.id }), id: \.id) { product in
        ProductItemView(product: product, extras: [.checkInCheck, .rating])
          .contentShape(Rectangle())
          .accessibilityAddTraits(.isLink)
          .onTapGesture {
            router.navigate(to: .product(product), resetStack: false)
          }
          .onAppear {
            if product == viewModel.products.last, viewModel.isLoading != true {
              Task {
                await viewModel.fetchProductFeedItems()
              }
            }
          }
      }
      if viewModel.isLoading {
        ProgressView()
          .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
          .listRowSeparator(.hidden)
      }
    }
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
    .refreshable {
      await viewModel.refresh()
    }
    .navigationTitle(viewModel.feed.label)
    .task {
      await viewModel.refresh()
    }
  }
}

extension ProductFeedScreen {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ProductFeedView")
    let client: Client
    @Published var products = [Product.Joined]()
    @Published var isLoading = false
    private let pageSize = 10
    private var page = 0

    let feed: ProductFeedType

    init(_ client: Client, feed: ProductFeedType) {
      self.client = client
      self.feed = feed
    }

    func refresh() async {
      page = 0
      products = [Product.Joined]()
      await fetchProductFeedItems()
    }

    func getPagination(page: Int, size: Int) -> (Int, Int) {
      let limit = size + 1
      let from = page * limit
      let to = from + size
      return (from, to)
    }

    func fetchProductFeedItems(onComplete: (() -> Void)? = nil) async {
      let (from, to) = getPagination(page: page, size: pageSize)

      isLoading = true

      switch await client.product.getFeed(feed, from: from, to: to) {
      case let .success(additionalProducts):
        products.append(contentsOf: additionalProducts)
        page += 1
        isLoading = false
        if let onComplete {
          onComplete()
        }
      case let .failure(error):
        logger.error("fetching check-ins failed: \(error.localizedDescription)")
      }
    }
  }
}
