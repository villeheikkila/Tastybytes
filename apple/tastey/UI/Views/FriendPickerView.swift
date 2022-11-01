import AlertToast
import SwiftUI

struct FriendPickerView: View {
    @Binding var taggedFriends: [Profile]
    @StateObject var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss

    func toggleFriend(friend: Profile) {
        DispatchQueue.main.async {
            if taggedFriends.contains(friend) {
                self.taggedFriends.remove(object: friend)
            } else {
                self.taggedFriends.append(friend)
            }
        }
    }

    var body: some View {
        NavigationStack {
            List(viewModel.friends, id: \.self) { friend in
                Button(action: {
                    toggleFriend(friend: friend)
                }) {
                    AvatarView(avatarUrl: friend.getAvatarURL(), size: 32, id: friend.id)
                    Text(friend.getPreferredName())
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

extension FriendPickerView {
    @MainActor class ViewModel: ObservableObject {
        @Published var friends = [Profile]()

        func loadFriends() {
            let currentUserId = repository.auth.getCurrentUserId()
            Task {
                let acceptedFriends = try await repository.friend.getByUserId(userId: currentUserId, status: .accepted)
                self.friends = acceptedFriends.map { $0.getFriend(userId: currentUserId) }
            }
        }
    }
}
