import SwiftUI

struct UserSheet: View {
  private let logger = getLogger(category: "UserSheet")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var friendManager: FriendManager
  @EnvironmentObject private var hapticManager: HapticManager
  @Environment(\.dismiss) private var dismiss
  @State private var searchText: String = ""
  @State private var searchResults = [Profile]()

  let onSubmit: () -> Void
  let mode: Mode

  init(
    mode: Mode,
    onSubmit: @escaping () -> Void
  ) {
    self.mode = mode
    self.onSubmit = onSubmit
  }

  var body: some View {
    List {
      ForEach(searchResults) { profile in
        HStack {
          AvatarView(avatarUrl: profile.avatarUrl, size: 32, id: profile.id)
          Text(profile.preferredName)
          Spacer()
          HStack {
            if mode == .add {
              HStack {
                if !friendManager.friends.contains(where: { $0.containsUser(userId: profile.id) }) {
                  ProgressButton("Add as a friend", systemImage: "person.badge.plus", action: {
                    await friendManager.sendFriendRequest(receiver: profile.id, onSuccess: {
                      dismiss()
                      onSubmit()
                    })
                    hapticManager.trigger(.impact(intensity: .low))
                  })
                  .labelStyle(.iconOnly)
                  .imageScale(.large)
                }
              }
            }
            if mode == .block {
              if !friendManager.blockedUsers.contains(where: { $0.containsUser(userId: profile.id) }) {
                ProgressButton(
                  "Block",
                  systemImage: "person.fill.xmark",
                  action: { await friendManager.blockUser(user: profile, onSuccess: {
                    onSubmit()
                    dismiss()
                  })
                  }
                )
                .imageScale(.large)
              }
            }
          }
        }
      }
    }
    .navigationTitle("Search users")
    .navigationBarItems(leading: Button("Cancel", role: .cancel, action: { dismiss() }))
    .searchable(text: $searchText)
    .disableAutocorrection(true)
    .onSubmit(of: .search) { Task { await searchUsers(currentUserId: profileManager.getId()) }
    }
  }

  func searchUsers(currentUserId: UUID) async {
    switch await repository.profile.search(searchTerm: searchText, currentUserId: currentUserId) {
    case let .success(searchResults):
      withAnimation {
        self.searchResults = searchResults
      }
    case let .failure(error):
      logger.error("failed searching users: \(error.localizedDescription)")
    }
  }
}

extension UserSheet {
  enum Mode {
    case add
    case block
  }
}
