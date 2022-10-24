import SwiftUI

struct UserSearchView<Actions: View>: View {
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

extension UserSearchView {
    @MainActor class ViewModel: ObservableObject {
        @Published var searchText: String = ""
        @Published var searchResults = [Profile]()
        
        func searchUsers() {
            Task {
                do {
                    let currentUserId = repository.auth.getCurrentUserId()
                    let searchResults = try await repository.profile.search(searchTerm: searchText, currentUserId: currentUserId)
                    DispatchQueue.main.async {
                        self.searchResults = searchResults
                    }
                } catch {
                    print("error: \(error.localizedDescription)")
                }
            }
        }
    }
}
