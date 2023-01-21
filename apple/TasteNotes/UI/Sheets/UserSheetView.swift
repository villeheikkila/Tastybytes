import SwiftUI

struct UserSheetView<Actions: View>: View {
  @StateObject private var viewModel = ViewModel()

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
    .searchable(text: $viewModel.searchText)
    .onSubmit(of: .search) { viewModel.searchUsers() }
  }
}

extension UserSheetView {
  @MainActor class ViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults = [Profile]()

    func searchUsers() {
      Task {
        let currentUserId = await repository.auth.getCurrentUserId()
        switch await repository.profile.search(searchTerm: searchText, currentUserId: currentUserId) {
        case let .success(searchResults):
          await MainActor.run {
            self.searchResults = searchResults
          }
        case let .failure(error):
          print(error)
        }
      }
    }
  }
}
