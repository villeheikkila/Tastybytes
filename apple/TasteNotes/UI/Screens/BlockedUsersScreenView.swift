import SwiftUI

struct BlockedUsersScreenView: View {
  @StateObject private var viewModel = ViewModel()
  @EnvironmentObject var profileManager: ProfileManager

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
    .navigationBarTitleDisplayMode(.inline)
    .task {
      viewModel.loadBlockedUsers(userId: profileManager.getId())
    }
  }

  struct BlockedUserListItemView: View {
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
}

extension BlockedUsersScreenView {
  @MainActor class ViewModel: ObservableObject {
    @Published var blockedUsers = [Friend]()
    @Published var error: Error?

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

    func loadBlockedUsers(userId: UUID?) {
      if let userId {
        Task {
          switch await repository.friend.getByUserId(userId: userId, status: .blocked) {
          case let .success(blockedUsers):
            await MainActor.run {
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
