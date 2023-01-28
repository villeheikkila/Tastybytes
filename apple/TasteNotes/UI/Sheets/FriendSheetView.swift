import SwiftUI

struct FriendSheetView: View {
  @Binding var taggedFriends: [Profile]
  @StateObject private var viewModel = ViewModel()
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    List(viewModel.friends, id: \.self) { friend in
      Button(action: {
        withAnimation {
          toggleFriend(friend: friend)
        }
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
    .task {
      viewModel.loadFriends()
    }
  }

  private func toggleFriend(friend: Profile) {
    if taggedFriends.contains(friend) {
      taggedFriends.remove(object: friend)
    } else {
      taggedFriends.append(friend)
    }
  }
}

extension FriendSheetView {
  @MainActor class ViewModel: ObservableObject {
    @Published var friends = [Profile]()

    func loadFriends() {
      Task {
        let currentUserId = await repository.auth.getCurrentUserId()

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
