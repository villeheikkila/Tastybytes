import Components

import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct FriendsScreen: View {
    private let logger = Logger(category: "FriendsScreen")
    @Environment(Repository.self) private var repository
    @Environment(ProfileModel.self) private var profileModel
    @State private var state: ScreenState = .loading
    @State private var friends: [Friend.Saved]
    @State private var searchTerm = ""
    @State private var isRefreshing = false

    let profile: Profile.Saved

    init(profile: Profile.Saved, initialFriends: [Friend.Saved]? = []) {
        self.profile = profile
        _friends = State(wrappedValue: initialFriends ?? [])
    }

    private var filteredFriends: [Friend.Saved] {
        if searchTerm.isEmpty {
            friends
        } else {
            friends.filter {
                $0.getFriend(userId: profile.id).preferredName.localizedCaseInsensitiveContains(searchTerm)
            }
        }
    }

    var body: some View {
        List(filteredFriends) { friend in
            FriendListItemView(profile: friend.getFriend(userId: profile.id)) {}
        }
        .listStyle(.plain)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .refreshable {
            isRefreshing = true
            await loadFriends()
            isRefreshing = false
        }
        .navigationTitle("friends.title \(friends.count.formatted())")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if state.isPopulated {
                if !searchTerm.isEmpty, filteredFriends.isEmpty {
                    ContentUnavailableView.search(text: searchTerm)
                }
            } else {
                ScreenStateOverlayView(state: state) {
                    await loadFriends()
                }
            }
        }
        .toolbar {
            toolbarContent
        }
        .sensoryFeedback(.success, trigger: isRefreshing) { oldValue, newValue in
            oldValue && !newValue
        }
        .initialTask {
            await loadFriends()
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if profileModel.hasNoFriendStatus(friend: profile) {
                AsyncButton(
                    "friends.add.label",
                    systemImage: "person.fill.badge.plus",
                    action: { await profileModel.sendFriendRequest(receiver: profile.id) }
                )
                .labelStyle(.iconOnly)
                .imageScale(.large)
            }
        }
    }

    private func loadFriends() async {
        do { let friends = try await repository.friend.getByUserId(id: profile.id, status: .accepted)
            withAnimation {
                self.friends = friends
                state = .populated
            }
        } catch {
            guard !error.isCancelled else { return }
            if state != .populated {
                state = .error(error)
            }
            logger.error("Failed to load friends' . Error: \(error) (\(#file):\(#line))")
        }
    }
}

public extension Friend.Status {
    var label: LocalizedStringKey {
        switch self {
        case .accepted:
            "friend.status.accepted"
        case .blocked:
            "friend.status.blocked"
        case .pending:
            "friend.status.pending"
        }
    }
}
