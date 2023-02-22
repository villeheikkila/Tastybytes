import SwiftUI

struct UserSheetView<Actions: View>: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.dismiss) private var dismiss

  let actions: (_ profile: Profile) -> Actions

  init(
    _ client: Client,
    actions: @escaping (_ profile: Profile) -> Actions
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
    self.actions = actions
  }

  var body: some View {
    List {
      ForEach(viewModel.searchResults, id: \.id) { profile in
        HStack {
          AvatarView(avatarUrl: profile.avatarUrl, size: 32, id: profile.id)
          Text(profile.preferredName)
          Spacer()
          HStack {
            self.actions(profile)
          }
        }
      }
    }
    .navigationTitle("Search users")
    .navigationBarItems(trailing: Button(role: .cancel, action: { dismiss() }, label: {
      Text("Cancel").bold()
    }))
    .searchable(text: $viewModel.searchText)
    .onSubmit(of: .search) { viewModel.searchUsers(currentUserId: profileManager.getId()) }
  }
}
