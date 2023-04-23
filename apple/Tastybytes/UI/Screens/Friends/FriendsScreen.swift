import SwiftUI

struct FriendsScreen: View {
  private let logger = getLogger(category: "FriendsScreen")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var friendManager: FriendManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @State private var friends: [Friend]

  let profile: Profile

  init(profile: Profile, initialFriends: [Friend]? = []) {
    self.profile = profile
    _friends = State(wrappedValue: initialFriends ?? [])
  }

  var body: some View {
    List {
      ForEach(friends) { friend in
        FriendListItemView(profile: friend.getFriend(userId: profile.id)) {}
      }
      .listStyle(.insetGrouped)
      .navigationTitle("Friends (\(friends.count))")
      .navigationBarTitleDisplayMode(.inline)
    }
    .refreshable {
      await feedbackManager.wrapWithHaptics {
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
          action: { await friendManager.sendFriendRequest(receiver: profile.id) }
        )
        .labelStyle(.iconOnly)
        .imageScale(.large)
      }
    }
  }

  func loadFriends() async {
    switch await repository.friend.getByUserId(
      userId: profile.id,
      status: Friend.Status.accepted
    ) {
    case let .success(friends):
      self.friends = friends
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to load friends' : \(error.localizedDescription)")
    }
  }
}
