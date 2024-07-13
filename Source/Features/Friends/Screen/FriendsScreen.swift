import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct FriendsScreen: View {
    private let logger = Logger(category: "FriendsScreen")
    @Environment(Repository.self) private var repository
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var state: ScreenState = .loading
    @State private var friends: [Friend]
    @State private var searchTerm = ""
    @State private var isRefreshing = false

    let profile: Profile

    init(profile: Profile, initialFriends: [Friend]? = []) {
        self.profile = profile
        _friends = State(wrappedValue: initialFriends ?? [])
    }

    private var filteredFriends: [Friend] {
        friends.filter { f in
            searchTerm.isEmpty ||
                f.getFriend(userId: profile.id).preferredName.lowercased()
                .contains(searchTerm.lowercased())
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
            if state == .populated {
                if !searchTerm.isEmpty, filteredFriends.isEmpty {
                    ContentUnavailableView.search(text: searchTerm)
                }
            } else {
                ScreenStateOverlayView(state: state, errorDescription: "", errorAction: {
                    await loadFriends()
                })
            }
        }
        .toolbar {
            toolbarContent
        }
        .sensoryFeedback(.success, trigger: isRefreshing) { oldValue, newValue in
            oldValue && !newValue
        }
        .sensoryFeedback(.success, trigger: friendEnvironmentModel.friends) { oldValue, newValue in
            newValue.count > oldValue.count
        }
        .initialTask {
            await loadFriends()
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if friendEnvironmentModel.hasNoFriendStatus(friend: profile) {
                AsyncButton(
                    "friends.add.label",
                    systemImage: "person.fill.badge.plus",
                    action: { await friendEnvironmentModel.sendFriendRequest(receiver: profile.id) }
                )
                .labelStyle(.iconOnly)
                .imageScale(.large)
            }
        }
    }

    func loadFriends() async {
        do { let friends = try await repository.friend.getByUserId(userId: profile.id, status: .accepted)
            withAnimation {
                self.friends = friends
                state = .populated
            }
        } catch {
            guard !error.isCancelled else { return }
            if state != .populated {
                state = .error([error])
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
