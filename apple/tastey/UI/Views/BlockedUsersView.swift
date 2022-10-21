import AlertToast
import Foundation
import SwiftUI

struct BlockedUsersView: View {
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject var currentProfile: CurrentProfile

    var body: some View {
            List {
                if viewModel.blockedUsers.isEmpty {
                    Text("You haven't blocked any users")
                }
                ForEach(viewModel.blockedUsers, id: \.self) { friend in
                    BlockedUserListItemView(profile: friend.getFriend(userId: currentProfile.profile?.id), onUnblockUser: {
                        viewModel.unblockUser(id: friend.id)
                    })
                    }
                }
            .navigationTitle("Blocked Users")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                viewModel.loadBlockedUsers(currentProfile: currentProfile.profile)
            }
            }
}

extension BlockedUsersView {
   @MainActor class ViewModel: ObservableObject {
        @Published var blockedUsers = [Friend]()
        @Published var error: Error?


        func unblockUser(id: Int) {
            Task {
                do {
                    try await repository.friend.delete(id: id)
                    DispatchQueue.main.async {
                        self.blockedUsers.removeAll(where: { $0.id == id })
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.error = error
                    }
                }
            }
        }

       func loadBlockedUsers(currentProfile: Profile?) {
           if let userId = currentProfile?.id {
               Task {
                   do {
                       let blockedUsers = try await repository.friend.getByUserId(userId: userId, status: .blocked)
                       print(blockedUsers)
                       DispatchQueue.main.async {
                           self.blockedUsers = blockedUsers
                       }
                   } catch {
                       DispatchQueue.main.async {
                           self.error = error
                       }
                   }
               }
           }
       }
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
                    Text(profile.getPreferedName())
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
