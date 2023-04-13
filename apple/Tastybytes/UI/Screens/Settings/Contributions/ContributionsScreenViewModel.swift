import SwiftUI

extension ContributionsScreen {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ContributionsScreen")
    let client: Client
    @Published var contributions: Contributions?
    @Published var activeSheet: Sheet?

    init(_ client: Client) {
      self.client = client
    }

    func loadContributions(userId: UUID) async {
      switch await client.profile.getContributions(userId: userId) {
      case let .success(contributions):
        withAnimation {
          self.contributions = contributions
        }
      case let .failure(error):
        logger.error("failed to load contributions: \(error.localizedDescription)")
      }
    }
  }
}
