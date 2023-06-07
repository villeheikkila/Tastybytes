import SwiftUI

struct FriendsScreen: View {
  private let logger = getLogger(category: "FriendsScreen")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(FriendManager.self) private var friendManager
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
    #if !targetEnvironment(macCatalyst)
    .refreshable {
      await feedbackManager.wrapWithHaptics {
        await loadFriends()
      }
    }
    #endif
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
      if friendManager.hasNoFriendStatus(friend: profile) {
        ProgressButton(
          "Add friend",
          systemSymbol: .personFillBadgePlus,
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
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to load friends' : \(error.localizedDescription)")
    }
  }
}
