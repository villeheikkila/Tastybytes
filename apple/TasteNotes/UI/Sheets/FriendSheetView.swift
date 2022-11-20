import SwiftUI

struct FriendSheetView: View {
    @Binding var taggedFriends: [Profile]
    @StateObject var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss

    func toggleFriend(friend: Profile) {
        if taggedFriends.contains(friend) {
            taggedFriends.remove(object: friend)
        } else {
            taggedFriends.append(friend)
        }
    }

    var body: some View {
        NavigationStack {
            List(viewModel.friends, id: \.self) { friend in
                Button(action: {
                    toggleFriend(friend: friend)
                }) {
                    AvatarView(avatarUrl: friend.getAvatarURL(), size: 32, id: friend.id)
                    Text(friend.preferredName)
                    Spacer()
                    if taggedFriends.contains(friend) {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .buttonStyle(.plain)
            .navigationTitle("Friends")
            .navigationBarItems(trailing: Button(action: {
                dismiss()
            }) {
                Text("Done").bold()
            })
        }.task {
            viewModel.loadFriends()
        }
    }
}

extension FriendSheetView {
    @MainActor class ViewModel: ObservableObject {
        @Published var friends = [Profile]()

        func loadFriends() {
            let currentUserId = repository.auth.getCurrentUserId()
            Task {
                switch await repository.friend.getByUserId(userId: currentUserId, status: .accepted) {
                case let .success(acceptedFriends):
                    self.friends = acceptedFriends.map { $0.getFriend(userId: currentUserId) }
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
}
