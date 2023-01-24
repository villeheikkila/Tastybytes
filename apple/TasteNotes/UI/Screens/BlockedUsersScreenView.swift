import SwiftUI

struct BlockedUsersScreenView: View {
  @StateObject private var viewModel = ViewModel()
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var toastManager: ToastManager

  var body: some View {
    List {
      if viewModel.blockedUsers.isEmpty {
        Text("You haven't blocked any users")
      }
      ForEach(viewModel.blockedUsers, id: \.self) { friend in
        BlockedUserListItemView(profile: friend.getFriend(userId: profileManager.getId()), onUnblockUser: {
          viewModel.unblockUser(id: friend.id)
        })
      }
    }
    .navigationTitle("Blocked Users")
    .navigationBarItems(
      trailing: blockUser
    )
    .sheet(isPresented: $viewModel.showUserSearchSheet) {
      NavigationStack {
        UserSheetView(actions: { profile in
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
    @Published var blockedUsers = [Friend]()
    @Published var error: Error?
    @Published var showUserSearchSheet = false

    func unblockUser(id: Int) {
      Task {
        switch await repository.friend.delete(id: id) {
        case .success:
          await MainActor.run {
            self.blockedUsers.removeAll(where: { $0.id == id })
          }
        case let .failure(error):
          await MainActor.run {
            self.error = error
          }
        }
      }
    }

    func blockUser(user: Profile, onSuccess: @escaping () -> Void, onFailure: @escaping (_ error: String) -> Void) {
      Task {
        switch await repository.friend.insert(newFriend: Friend.NewRequest(receiver: user.id, status: .blocked)) {
        case let .success(blockedUser):
          await MainActor.run {
            self.blockedUsers.append(blockedUser)
            onSuccess()
          }
        case let .failure(error):
          await MainActor.run {
            onFailure(error.localizedDescription)
          }
        }
      }
    }

    func loadBlockedUsers(userId: UUID?) {
      if let userId {
        Task {
          switch await repository.friend.getByUserId(userId: userId, status: .blocked) {
          case let .success(blockedUsers):
            await MainActor.run {
              print(blockedUsers)
              self.blockedUsers = blockedUsers
            }
          case let .failure(error):
            await MainActor.run {
              self.error = error
            }
          }
        }
      }
    }
  }
}
