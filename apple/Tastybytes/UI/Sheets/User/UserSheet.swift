import SwiftUI

struct UserSheet: View {
  enum Mode {
    case add
    case block
  }

  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var friendManager: FriendManager
  @EnvironmentObject private var hapticManager: HapticManager
  @Environment(\.dismiss) private var dismiss

  let onSubmit: () -> Void
  let mode: Mode

  init(
    _ client: Client,
    mode: Mode,
    onSubmit: @escaping () -> Void
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
    self.mode = mode
    self.onSubmit = onSubmit
  }

  var body: some View {
    List {
      ForEach(viewModel.searchResults) { profile in
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
                  }) }
                )
                .imageScale(.large)
              }
            }
          }
        }
      }
    }
    .navigationTitle("Search users")
    .navigationBarItems(leading: Button(role: .cancel, action: { dismiss() }, label: {
      Text("Cancel").bold()
    }))
    .searchable(text: $viewModel.searchText)
    .disableAutocorrection(true)
    .onSubmit(of: .search) { Task { await viewModel.searchUsers(currentUserId: profileManager.getId()) }
    }
  }
}
