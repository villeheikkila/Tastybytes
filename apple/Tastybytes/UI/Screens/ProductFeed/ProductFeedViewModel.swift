import SwiftUI

extension ProductFeedScreen {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ProductFeedScreen")
    let client: Client
    @Published var products = [Product.Joined]()
    let feed: ProductFeedType

    init(_ client: Client, feed: ProductFeedType) {
      self.client = client
      self.feed = feed
    }

    func load() async {
      switch feed {
      case .trending:
        await getTrendingProductFeed()
      case .topRated:
        await getTopRatedProductFeed()
      }
    }

    func getTopRatedProductFeed() async {
      switch await client.product.getFeed(.topRated) {
      case let .success(result):
        products = result
      case let .failure(error):
        logger.error("failed to load top rated feed: \(error.localizedDescription)")
      }
    }

    func getTrendingProductFeed() async {
      switch await client.product.getFeed(.trending) {
      case let .success(result):
        products = result
      case let .failure(error):
        logger.error("failed to load trending feed: \(error.localizedDescription)")
      }
    }
  }
}
