import Foundation
import SwiftUI

struct FriendsView: View {
    @State private var products = [Product]()
    @StateObject private var model = FriendsViewModel()
    @State private var searchText = ""
    @State private var showingSheet = false

    var body: some View {
        List {
            ForEach(model.friends, id: \.id) { friend in
                FriendListItem(profile: friend.getFriend(userId: SupabaseAuthRepository().getCurrentUserId()))
            }
        }.task {
            model.loadFriends(userId: SupabaseAuthRepository().getCurrentUserId())
        }   .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.inline)

        
        
        Button(action: {
            showingSheet.toggle()
        }) {
            Text("Find users")
        }
            .sheet(isPresented: $showingSheet) {

            }
    }
}

struct UserSearchView: View {
    @ObservedObject var model = UserSearchViewModel()
    
    var body: some View {
        List {
            ForEach(model.searchResults, id: \.id) { profile in
                    FriendListItem(profile: profile)
            }
        }
        .searchable(text: $model.searchText)
        .navigationTitle("Search users")
        .onSubmit(of: .search, model.searchUsers)
    }
}

extension UserSearchView {
    class UserSearchViewModel: ObservableObject {
        @Published var searchText: String = ""
        @Published var searchResults = [Profile]()

        func searchUsers() {
            Task {
                let searchResults = try await SupabaseProfileRepository().search(searchTerm: searchText)
                DispatchQueue.main.async {
                    self.searchResults = searchResults
                }
            }
        }
    }
}


struct FriendListItem: View {
    let profile: Profile
    let onFriendRequestSent: ((_ receiver: UUID) -> Void)?

    init(profile: Profile, onFriendRequestSent: ((_ receiver: UUID) -> Void)? = nil) {
        self.profile = profile
        self.onFriendRequestSent = onFriendRequestSent
    }

    var body: some View {
        HStack {
            NavigationLink(value: profile) {
                HStack {
                    AvatarView(avatarUrl: profile.getAvatarURL(), size: 32, id: profile.id)
                    Text(profile.username)
                }
            }
            Spacer()
            if let onFriendRequestSent = onFriendRequestSent {
                Button(action: {
                    onFriendRequestSent(profile.id)
                }) {
                    Image(systemName: "person.badge.plus")
                }
            }
        }
    }
}

extension FriendsView {
    class FriendsViewModel: ObservableObject {
        @Published var searchText: String = ""
        @Published var products = [Profile]()
        @Published var friends = [Friend]()

        func sendFriendRequest(sender: UUID, receiver: UUID) {
            let newFriend = NewFriend(sender: sender, receiver: receiver)
            Task {
                let newFriend = try await SupabaseFriendsRepository().insert(newFriend: newFriend)
                print(newFriend)
            }
        }

        func loadFriends(userId: UUID) {
            Task {
                let friends = try await SupabaseFriendsRepository().loadByUserId(userId: userId)
                DispatchQueue.main.async {
                    self.friends = friends
                }
            }
        }

        func searchUsers() {
            Task {
                let searchResults = try await SupabaseProfileRepository().search(searchTerm: searchText)
                DispatchQueue.main.async {
                    self.products = searchResults
                }
            }
        }
    }
}
