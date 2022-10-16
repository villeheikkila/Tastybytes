import SwiftUI

struct UserSearchView<Actions: View>: View {
    @State var searchText: String = ""
    @State var searchResults = [Profile]()

    let actions: (_ userId: UUID) -> Actions

    var body: some View {
        VStack {
            HStack {
                TextField("Name", text: $searchText)
                Button("Search") {
                    searchUsers()
                }
            }
            VStack {
                ForEach(searchResults, id: \.id) { profile in
                    HStack {
                        AvatarView(avatarUrl: profile.getAvatarURL(), size: 32, id: profile.id)
                        Text(profile.username)
                        Spacer()
                        self.actions(profile.id)
                    }
                }
            }
        }
    }
    
    func searchUsers() {
        Task {
            do {
                let searchResults = try await SupabaseProfileRepository().search(searchTerm: searchText)
                DispatchQueue.main.async {
                    self.searchResults = searchResults
                }
            } catch {
                print("error: \(error.localizedDescription)")
            }
        }
    }
}
