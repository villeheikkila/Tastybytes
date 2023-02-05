import SwiftUI

struct BlockedUsersScreenView: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var toastManager: ToastManager

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

  var body: some View {
    List {
      if viewModel.blockedUsers.isEmpty {
        Text("You haven't blocked any users")
      }
      ForEach(viewModel.blockedUsers, id: \.self) { friend in
        BlockedUserListItemView(profile: friend.getFriend(userId: profileManager.getId()), onUnblockUser: {
          viewModel.unblockUser(friend)
        })
      }
    }
    .navigationTitle("Blocked Users")
    .navigationBarItems(
      trailing: blockUser
    )
    .sheet(isPresented: $viewModel.showUserSearchSheet) {
      NavigationStack {
        UserSheetView(viewModel.client, actions: { profile in
          HStack {
            if !viewModel.blockedUsers.contains(where: { $0.containsUser(userId: profile.id) }) {
              Button(action: { viewModel.blockUser(user: profile, onSuccess: {
                toastManager.toggle(.success("User blocked"))
              }, onFailure: {
                error in toastManager.toggle(.error(error))
              }) }) {
                Label("Block", systemImage: "person.fill.xmark")
                  .imageScale(.large)
              }
            }
          }
        })
      }
      .presentationDetents([.medium])
    }
    .navigationBarTitleDisplayMode(.inline)
    .task {
      viewModel.loadBlockedUsers(userId: profileManager.getId())
    }
  }

  private var blockUser: some View {
    HStack {
      Button(action: { viewModel.showUserSearchSheet.toggle() }) {
        Image(systemName: "plus").imageScale(.large)
      }
    }
  }
}

private struct BlockedUserListItemView: View {
  let profile: Profile
  let onUnblockUser: () -> Void

  var body: some View {
    HStack(alignment: .center) {
      AvatarView(avatarUrl: profile.getAvatarURL(), size: 32, id: profile.id)
      VStack {
        HStack {
          Text(profile.preferredName)
          Spacer()
          Button(action: {
            onUnblockUser()
          }) {
            Label("Unblock", systemImage: "hand.raised.slash.fill")
          }
        }
      }
    }
  }
}

extension BlockedUsersScreenView {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "BlockedUsersScreenView")
    let client: Client
    @Published var blockedUsers = [Friend]()
    @Published var error: Error?
    @Published var showUserSearchSheet = false

    init(_ client: Client) {
      self.client = client
    }

    func unblockUser(_ friend: Friend) {
      Task {
        switch await client.friend.delete(id: friend.id) {
        case .success:
          withAnimation {
            self.blockedUsers.remove(object: friend)
          }
        case let .failure(error):
          logger.warning("failed to unblock user \(friend.id): \(error.localizedDescription)")
          self.error = error
        }
      }
    }

    func blockUser(user: Profile, onSuccess: @escaping () -> Void, onFailure: @escaping (_ error: String) -> Void) {
      Task {
        switch await client.friend.insert(newFriend: Friend.NewRequest(receiver: user.id, status: .blocked)) {
        case let .success(blockedUser):
          withAnimation {
            self.blockedUsers.append(blockedUser)
          }
          onSuccess()
        case let .failure(error):
          logger.warning("failed to block user \(user.id): \(error.localizedDescription)")
          onFailure(error.localizedDescription)
        }
      }
    }

    func loadBlockedUsers(userId: UUID?) {
      if let userId {
        Task {
          switch await client.friend.getByUserId(userId: userId, status: .blocked) {
          case let .success(blockedUsers):
            withAnimation {
              self.blockedUsers = blockedUsers
            }
          case let .failure(error):
            logger.warning("failed to load blocked users: \(error.localizedDescription)")
            self.error = error
          }
        }
      }
    }
  }
}
