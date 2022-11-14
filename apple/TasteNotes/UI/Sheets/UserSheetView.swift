import SwiftUI

struct UserSheetView<Actions: View>: View {
    @StateObject var viewModel = ViewModel()

    let actions: (_ profile: Profile) -> Actions

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.searchResults, id: \.id) { profile in
                    HStack {
                        AvatarView(avatarUrl: profile.getAvatarURL(), size: 32, id: profile.id)
                        Text(profile.getPreferredName())
                        Spacer()
                        HStack {
                            self.actions(profile)
                        }
                    }
                }
            }
            .navigationTitle("Search users")
            .searchable(text: $viewModel.searchText)
            .onSubmit(of: .search, { viewModel.searchUsers() })
        }
    }
}

extension UserSheetView {
    @MainActor class ViewModel: ObservableObject {
        @Published var searchText: String = ""
        @Published var searchResults = [Profile]()

        func searchUsers() {
            Task {
                let currentUserId = repository.auth.getCurrentUserId()
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
