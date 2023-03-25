import SwiftUI

@MainActor class AppDataManager: ObservableObject {
  private let logger = getLogger(category: "AppDataManager")
  let client: Client
  @Published var categories = [Category.JoinedSubcategories]()
  @Published var flavors = [Flavor]()

  init(_ client: Client) {
    self.client = client
  }

  func initialize() async {
    async let flavorPromise = client.flavor.getAll()
    async let categoryPromise = client.category.getAllWithSubcategories()

    switch await flavorPromise {
    case let .success(flavors):
      withAnimation {
        self.flavors = flavors
      }
    case let .failure(error):
      logger.error("fetching flavors failed: \(error.localizedDescription)")
    }

    switch await categoryPromise {
    case let .success(categories):
      self.categories = categories
    case let .failure(error):
      logger
        .error("failed to load categories: \(error.localizedDescription)")
    }
  }
}
