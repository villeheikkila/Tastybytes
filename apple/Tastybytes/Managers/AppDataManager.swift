import SwiftUI

@MainActor class AppDataManager: ObservableObject {
  private let logger = getLogger(category: "AppDataManager")
  let client: Client
  @Published var categories = [Category.JoinedSubcategories]()
  @Published var flavors = [Flavor]()

  init(_ client: Client) {
    self.client = client
  }

  func loadFlavors() async {
    switch await client.flavor.getAll() {
    case let .success(flavors):
      withAnimation {
        self.flavors = flavors
      }
    case let .failure(error):
      logger
        .error(
          "fetching flavors failed: \(error.localizedDescription)"
        )
    }
  }

  func loadCategories(_: String) {
    Task {
      switch await client.category.getAllWithSubcategories() {
      case let .success(categories):
        self.categories = categories
      case let .failure(error):
        logger
          .error("failed to load categories: \(error.localizedDescription)")
      }
    }
  }
}
