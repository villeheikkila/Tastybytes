import SwiftUI

struct FriendsScreen: View {
  private let logger = getLogger(category: "FriendsScreen")
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var friendManager: FriendManager
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var toastManager: ToastManager
  @State private var friends: [Friend]

  let client: Client
  let profile: Profile

  init(_ client: Client, profile: Profile, initialFriends: [Friend]? = []) {
    self.client = client
    self.profile = profile
    _friends = State(wrappedValue: initialFriends ?? [])
  }

  var body: some View {
    List {
      ForEach(friends) { friend in
        FriendListItemView(profile: friend.getFriend(userId: profile.id)) {}
      }
      .navigationTitle("Friends (\(friends.count))")
      .navigationBarTitleDisplayMode(.inline)
    }
    .refreshable {
      await hapticManager.wrapWithHaptics {
        await loadFriends()
      }
    }
    .task {
      if friends.isEmpty {
        await loadFriends()
      }
    }
    .toolbar {
      toolbarContent
    }
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      if !friendManager.isFriend(profile) {
        ProgressButton(
          "Add friend",
          systemImage: "person.badge.plus",
          action: { await friendManager.sendFriendRequest(receiver: profile.id) {
            toastManager.toggle(.success("Friend Request Sent!"))
          }
          }
        )
        .labelStyle(.iconOnly)
        .imageScale(.large)
      }
    }
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
