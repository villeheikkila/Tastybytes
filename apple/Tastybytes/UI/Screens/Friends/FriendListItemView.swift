import SwiftUI

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
