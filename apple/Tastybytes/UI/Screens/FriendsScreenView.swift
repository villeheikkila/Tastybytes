import SwiftUI

struct CurrentUserFriendsScreenView: View {
  let client: Client
  @EnvironmentObject private var profileManager: ProfileManager

  init(_ client: Client) {
    self.client = client
  }

  var body: some View {
    FriendsScreenView(client, profile: profileManager.getProfile())
  }
}

struct FriendsScreenView: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var toastManager: ToastManager
  @EnvironmentObject private var noficationManager: NotificationManager

  init(_ client: Client, profile: Profile) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, profile: profile))
  }

  var body: some View {
    ScrollView {
      ForEach(viewModel.friends, id: \.self) { friend in
        if viewModel.profile == profileManager.getProfile() {
          FriendListItemView(friend: friend,
                             currentUser: profileManager.getProfile(),
                             onAccept: { _ in
                               viewModel.updateFriendRequest(friend: friend, newStatus: .accepted)
                             },
                             onBlock: { _ in viewModel.updateFriendRequest(friend: friend, newStatus: .blocked) },
                             onDelete: { _ in
                               viewModel.friendToBeRemoved = friend
                             })
        } else {
          FriendListItemSimpleView(profile: friend.getFriend(userId: viewModel.profile.id))
        }
      }
      .navigationTitle("Friends")
      .navigationBarTitleDisplayMode(.inline)
    }
    .refreshable {
      viewModel.loadFriends(currentUser: profileManager.getProfile())
    }
    .task {
      viewModel.loadFriends(currentUser: profileManager.getProfile())
      if viewModel.profile == profileManager.getProfile() {
        noficationManager.markAllFriendRequestsAsRead()
      }
    }
    .navigationBarItems(
      trailing: addFriendButton
    )
    .sheet(isPresented: $viewModel.showUserSearchSheet) {
      NavigationStack {
        UserSheetView(viewModel.client, actions: { profile in
          HStack {
            if !viewModel.friends.contains(where: { $0.containsUser(userId: profile.id) }) {
              Button(action: { viewModel.sendFriendRequest(receiver: profile.id, onSuccess: {
                toastManager.toggle(.success("Friend Request Sent!"))
              }) }) {
                Image(systemName: "person.badge.plus")
                  .imageScale(.large)
              }
            }
          }
          .errorAlert(error: $viewModel.modalError)
        })
      }
      .presentationDetents([.medium])
    }
    .errorAlert(error: $viewModel.error)
    .confirmationDialog("Delete Friend Confirmation",
                        isPresented: $viewModel.showRemoveFriendConfirmation,
                        presenting: viewModel.friendToBeRemoved) { presenting in
      Button(
        "Remove \(presenting.getFriend(userId: profileManager.getId()).preferredName) from friends",
        role: .destructive,
        action: {
          withAnimation {
            viewModel.removeFriendRequest(presenting)
          }
        }
      )
    }
  }

  private var addFriendButton: some View {
    HStack {
      if viewModel.profile == profileManager.getProfile() {
        Button(action: { viewModel.showUserSearchSheet.toggle() }) {
          Image(systemName: "plus").imageScale(.large)
        }
      }
    }
  }
}

extension FriendsScreenView {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "FriendsScreenView")
    let client: Client
    @Published var searchText: String = ""
    @Published var products = [Profile]()
    @Published var friends = [Friend]()
    @Published var showUserSearchSheet = false
    @Published var error: Error?
    @Published var modalError: Error?
    @Published var friendToBeRemoved: Friend? {
      didSet {
        showRemoveFriendConfirmation = true
      }
    }

    @Published var showRemoveFriendConfirmation = false

    let profile: Profile

    init(_ client: Client, profile: Profile) {
      self.client = client
      self.profile = profile
    }

    func sendFriendRequest(receiver: UUID, onSuccess: @escaping () -> Void) {
      Task {
        switch await client.friend.insert(newFriend: Friend.NewRequest(receiver: receiver, status: .pending)) {
        case let .success(newFriend):
          withAnimation {
            self.friends.append(newFriend)
          }
          self.showUserSearchSheet = false
          onSuccess()
        case let .failure(error):
          logger.warning("failed add new friend '\(receiver)': \(error.localizedDescription)")
          self.modalError = error
        }
      }
    }

    func updateFriendRequest(friend: Friend, newStatus: Friend.Status) {
      let friendUpdate = Friend.UpdateRequest(
        sender: friend.sender,
        receiver: friend.receiver,
        status: newStatus
      )

      Task {
        switch await client.friend.update(id: friend.id, friendUpdate: friendUpdate) {
        case let .success(updatedFriend):

          if updatedFriend.status != Friend.Status.blocked {
            withAnimation {
              self.friends.replace(friend, with: updatedFriend)
            }
          } else {
            withAnimation {
              self.friends.remove(object: friend)
            }
          }
        case let .failure(error):
          logger
            .warning(
              """
              failed to update friend request '\(friend.id)' with status '\(newStatus.rawValue)':\
               \(error.localizedDescription)
              """
            )
          self.error = error
        }
      }
    }

    func removeFriendRequest(_ friend: Friend) {
      Task {
        switch await client.friend.delete(id: friend.id) {
        case .success:
          withAnimation {
            self.friends.remove(object: friend)
          }
          showRemoveFriendConfirmation = false
        case let .failure(error):
          logger.warning("failed to remove friend request '\(friend.id)': \(error.localizedDescription)")
          self.error = error
        }
      }
    }

    func loadFriends(currentUser: Profile) {
      Task {
        switch await client.friend.getByUserId(
          userId: profile.id,
          status: currentUser.id == profile.id ? .none : Friend.Status.accepted
        ) {
        case let .success(friends):
          self.friends = friends
        case let .failure(error):
          self.error = error
        }
      }
    }
  }
}

struct FriendListItemSimpleView: View {
  let profile: Profile

  var body: some View {
    NavigationLink(value: Route.profile(profile)) {
      HStack(alignment: .center) {
        AvatarView(avatarUrl: profile.avatarUrl, size: 32, id: profile.id)
        Text(profile.preferredName)
          .foregroundColor(.primary)
        Spacer()
      }
    }
    .padding(.all, 10)
    .background(Color(.tertiarySystemBackground))
    .cornerRadius(10)
    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
    .padding([.leading, .trailing], 10)
  }
}

struct FriendListItemView: View {
  let friend: Friend
  let profile: Profile
  let currentUser: Profile
  let onAccept: (_ friend: Friend) -> Void
  let onBlock: (_ friend: Friend) -> Void
  let onDelete: (_ friend: Friend) -> Void

  init(friend: Friend,
       currentUser: Profile,
       onAccept: @escaping (_ friend: Friend) -> Void,
       onBlock: @escaping (_ friend: Friend) -> Void,
       onDelete: @escaping (_ friend: Friend) -> Void)
  {
    self.friend = friend
    profile = friend.getFriend(userId: currentUser.id)
    self.currentUser = currentUser
    self.onAccept = onAccept
    self.onBlock = onBlock
    self.onDelete = onDelete
  }

  var body: some View {
    NavigationLink(value: Route.profile(friend.getFriend(userId: currentUser.id))) {
      HStack(alignment: .center) {
        AvatarView(avatarUrl: profile.avatarUrl, size: 32, id: profile.id)
        VStack {
          HStack {
            Text(profile.preferredName)
              .foregroundColor(.primary)
            if friend.status == Friend.Status.pending {
              Text("(\(friend.status.rawValue.capitalized))")
                .font(.footnote)
                .foregroundColor(.primary)
            }
            Spacer()
            if friend.isPending(userId: currentUser.id) {
              HStack(alignment: .center) {
                Button(action: {
                  onDelete(friend)
                }) {
                  Image(systemName: "person.fill.xmark")
                    .imageScale(.large)
                }

                Button(action: {
                  onAccept(friend)
                }) {
                  Image(systemName: "person.badge.plus")
                    .imageScale(.large)
                }
              }
            }
          }
        }
      }
    }
    .contextMenu {
      Button(action: {
        onDelete(friend)
      }) {
        Label("Delete", systemImage: "person.fill.xmark").imageScale(.large)
      }

      Button(action: {
        onBlock(friend)
      }) {
        Label("Block", systemImage: "person.2.slash").imageScale(.large)
      }
    }
    .padding(.all, 10)
    .background(Color(.tertiarySystemBackground))
    .cornerRadius(10)
    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 0)
    .padding([.leading, .trailing], 10)
  }
}
