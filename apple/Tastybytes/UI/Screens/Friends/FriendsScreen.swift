import SwiftUI

struct FriendsScreen: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var friendManager: FriendManager
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var toastManager: ToastManager

  init(_ client: Client, profile: Profile, initialFriends: [Friend] = []) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, profile: profile, initialFriends: initialFriends))
  }

  var body: some View {
    List {
      ForEach(viewModel.friends) { friend in
        FriendListItemView(profile: friend.getFriend(userId: viewModel.profile.id)) {}
      }
      .navigationTitle("Friends (\(viewModel.friends.count))")
      .navigationBarTitleDisplayMode(.inline)
    }
    .refreshable {
      await hapticManager.wrapWithHaptics {
        await viewModel.loadFriends()
      }
    }
    .task {
      if viewModel.friends.isEmpty {
        await viewModel.loadFriends()
      }
    }
    .toolbar {
      toolbarContent
    }
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      if !friendManager.isFriend(viewModel.profile) {
        ProgressButton(action: { await friendManager.sendFriendRequest(receiver: viewModel.profile.id) {
          toastManager.toggle(.success("Friend Request Sent!"))
        } }, label: {
          Label("Add friend", systemImage: "person.badge.plus")
            .labelStyle(.iconOnly)
            .imageScale(.large)
        })
      }
    }
  }
}
