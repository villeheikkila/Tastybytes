import SwiftUI

struct BlockedUsersScreen: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var toastManager: ToastManager

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

  var body: some View {
    List {
      if viewModel.blockedUsers.isEmpty {
        Text("You haven't blocked any users")
      }
      ForEach(viewModel.blockedUsers) { friend in
        BlockedUserListItemView(profile: friend.getFriend(userId: profileManager.getId()), onUnblockUser: {
          viewModel.unblockUser(friend)
        })
      }
    }
    .navigationTitle("Blocked Users")
    .navigationBarItems(
      trailing: blockUser
    )
    .sheet(isPresented: $viewModel.showUserSearchSheet) {
      NavigationStack {
        UserSheet(viewModel.client, actions: { profile in
          HStack {
            if !viewModel.blockedUsers.contains(where: { $0.containsUser(userId: profile.id) }) {
              Button(action: { viewModel.blockUser(user: profile, onSuccess: {
                toastManager.toggle(.success("User blocked"))
              }, onFailure: { error in
                toastManager.toggle(.error(error))
              }) }, label: {
                Label("Block", systemImage: "person.fill.xmark")
                  .imageScale(.large)
              })
            }
          }
        })
      }
      .presentationDetents([.medium])
    }
    .navigationBarTitleDisplayMode(.inline)
    .task {
      viewModel.loadBlockedUsers(userId: profileManager.getId())
    }
  }

  private var blockUser: some View {
    HStack {
      Button(action: { viewModel.showUserSearchSheet.toggle() }, label: {
        Label("Show block user sheet", systemImage: "plus")
          .labelStyle(.iconOnly)
          .imageScale(.large)
      })
    }
  }
}