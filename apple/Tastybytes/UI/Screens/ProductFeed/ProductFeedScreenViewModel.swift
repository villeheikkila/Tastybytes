import SwiftUI

extension ProductFeedScreen {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ProductFeedView")
    let client: Client
    @Published var products = [Product.Joined]()
    @Published var categoryFilter: Category.JoinedSubcategories? {
      didSet {
        Task { await refresh() }
      }
    }

    @Published var isLoading = false
    private let pageSize = 10
    private var page = 0

    var filteredProducts: [Product.Joined] {
      products.unique(selector: { $0.id == $1.id })
    }

    var title: String {
      if let categoryFilter {
        return "\(feed.label): \(categoryFilter.name)"
      } else {
        return feed.label
      }
    }

    let feed: Product.FeedType

    init(_ client: Client, feed: Product.FeedType) {
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

      switch await client.product.getFeed(feed, from: from, to: to, categoryFilterId: categoryFilter?.id) {
      case let .success(additionalProducts):
        withAnimation {
          products.append(contentsOf: additionalProducts)
        }
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
