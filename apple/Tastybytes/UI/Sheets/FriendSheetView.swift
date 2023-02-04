import SwiftUI

struct FriendSheetView: View {
  @Binding var taggedFriends: [Profile]
  @StateObject private var viewModel = ViewModel()
  @EnvironmentObject private var profileManager: ProfileManager
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
      viewModel.loadFriends(currentUserId: profileManager.getId())
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
    private let logger = getLogger(category: "FriendSheetView")
    @Published var friends = [Profile]()

    func loadFriends(currentUserId: UUID) {
      Task {
        // TODO: Make a view / db function to get this data directly
        switch await repository.friend.getByUserId(userId: currentUserId, status: .accepted) {
        case let .success(acceptedFriends):
          withAnimation {
            self.friends = acceptedFriends.map { $0.getFriend(userId: currentUserId) }
          }
        case let .failure(error):
          logger
            .error(
              "fetching friends failed: \(error.localizedDescription)"
            )
        }
      }
    }
  }
}
