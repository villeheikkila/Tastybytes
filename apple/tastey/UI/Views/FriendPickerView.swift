import AlertToast
import SwiftUI

struct FriendPickerView: View {
    @State var friends = [Profile]()
    @Binding var taggedFriends: [Profile]
    @State var showToast = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List(friends, id: \.self) { friend in
                Button(action: {
                    taggedFriends.append(friend)
                }) {
                    HStack {
                        AvatarView(avatarUrl: friend.getAvatarURL(), size: 32, id: friend.id)
                        Text(friend.getPreferedName())
                        
                        Spacer()
                        if taggedFriends.contains(where: { $0.id == friend.id }) {
                            Image(systemName: "checkmark")
                        }
                    }
                    
                }
            }
            .navigationTitle("Friends")
            .navigationBarItems(trailing: Button(action: {
                dismiss()
            }) {
                Text("Done").bold()
            })
        }.task {
            loadFriends()
        }
    }
    
    func loadFriends() {
        let currentUserId = repository.auth.getCurrentUserId()
        Task {
            let acceptedFriends = try await repository.friend.getByUserId(userId: currentUserId, status: .accepted)
            self.friends = acceptedFriends.map { $0.getFriend(userId: currentUserId) }
        }
    }
}
