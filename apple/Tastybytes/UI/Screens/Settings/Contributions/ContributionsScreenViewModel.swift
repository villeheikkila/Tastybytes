import SwiftUI

extension ContributionsScreen {
  enum Sheet: Identifiable {
    var id: Self { self }

    case products
  }

  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ContributionsScreen")
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
