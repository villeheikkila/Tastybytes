import AlertToast
import SwiftUI

struct FriendPickerView: View {
    let friends: [Profile]
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
                        Text(friend.username)
                        
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
        }
    }
}
