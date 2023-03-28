import SwiftUI

extension ContributionsScreen {
  enum Sheet: Identifiable {
    var id: Self { self }

    case products
  }

  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ContributionsScreen")
    let client: Client
    @Published var contributions: Contributions?
    @Published var activeSheet: Sheet?

    init(_ client: Client) {
      self.client = client
    }

    func loadContributions(userId: UUID) {
      Task {
        switch await client.profile.getContributions(userId: userId) {
        case let .success(contributions):
          withAnimation {
            self.contributions = contributions
          }
        case let .failure(error):
          logger.warning("failed to load contributions: \(error.localizedDescription)")
        }
      }
    }
  }
}
