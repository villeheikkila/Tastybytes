import SwiftUI

struct UserSheetView<Actions: View>: View {
  @StateObject private var viewModel = ViewModel()
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.dismiss) private var dismiss

  let actions: (_ profile: Profile) -> Actions

  var body: some View {
    List {
      ForEach(viewModel.searchResults, id: \.id) { profile in
        HStack {
          AvatarView(avatarUrl: profile.getAvatarURL(), size: 32, id: profile.id)
          Text(profile.preferredName)
          Spacer()
          HStack {
            self.actions(profile)
          }
        }
      }
    }
    .navigationTitle("Search users")
    .navigationBarItems(trailing: Button(action: {
      dismiss()
    }) {
      Text("Cancel").bold()
    })
    .searchable(text: $viewModel.searchText)
    .onSubmit(of: .search) { viewModel.searchUsers(currentUserId: profileManager.getId()) }
  }
}

extension UserSheetView {
  @MainActor class ViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults = [Profile]()

    func searchUsers(currentUserId: UUID) {
      Task {
        switch await repository.profile.search(searchTerm: searchText, currentUserId: currentUserId) {
        case let .success(searchResults):
          withAnimation {
            self.searchResults = searchResults
          }
        case let .failure(error):
          print(error)
        }
      }
    }
  }
}
