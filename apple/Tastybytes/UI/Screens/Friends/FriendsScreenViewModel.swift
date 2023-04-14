import SwiftUI

extension FriendsScreen {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "FriendsScreen")
    let client: Client
    @Published var friends: [Friend]

    let profile: Profile

    init(_ client: Client, profile: Profile, initialFriends: [Friend]) {
      self.client = client
      self.profile = profile
      friends = initialFriends
    }

    func loadFriends() async {
      switch await client.friend.getByUserId(
        userId: profile.id,
        status: Friend.Status.accepted
      ) {
      case let .success(friends):
        self.friends = friends
      case let .failure(error):
        logger.error("failed to load friends' : \(error.localizedDescription)")
      }
    }
  }
}
