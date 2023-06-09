import SwiftUI
import OSLog

struct UserSheet: View {
  private let logger = Logger(category: "UserSheet")
  @Environment(Repository.self) private var repository
  @Environment(ProfileManager.self) private var profileManager
  @Environment(FriendManager.self) private var friendManager
  @Environment(FeedbackManager.self) private var feedbackManager
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
                  ProgressButton("Add as a friend", systemSymbol: .personBadgePlus, action: {
                    await friendManager.sendFriendRequest(receiver: profile.id, onSuccess: {
                      dismiss()
                      onSubmit()
                    })
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
                  systemSymbol: .personFillXmark,
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
    .onSubmit(of: .search) { Task { await searchUsers(currentUserId: profileManager.id) }
    }
  }

  func searchUsers(currentUserId: UUID) async {
    switch await repository.profile.search(searchTerm: searchText, currentUserId: currentUserId) {
    case let .success(searchResults):
        await MainActor.run {
            withAnimation {
                self.searchResults = searchResults
            }
        }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
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
