import SwiftUI

extension FriendSheetView {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "FriendSheetView")
    let client: Client
    @Published var friends = [Profile]()

    init(_ client: Client) {
      self.client = client
    }

    func loadFriends(currentUserId: UUID) {
      Task {
        // TODO: Make a view / db function to get this data directly
        switch await client.friend.getByUserId(userId: currentUserId, status: .accepted) {
        case let .success(acceptedFriends):
          withAnimation {
            self.friends = acceptedFriends.map { $0.getFriend(userId: currentUserId) }
          }
        case let .failure(error):
          logger
            .error(
              "fetching friends failed: \(error.localizedDescription)"
            )
        }
      }
    }
  }
}
