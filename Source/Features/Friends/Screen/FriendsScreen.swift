import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct FriendsScreen: View {
    private let logger = Logger(category: "FriendsScreen")
    @Environment(\.repository) private var repository
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var friends: [Friend]
    @State private var searchTerm = ""
    @State private var alertError: AlertError?
    @State private var isRefreshing = false
    @State private var refreshId = 0
    @State private var resultId: Int?

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
        .listStyle(.insetGrouped)
        .navigationTitle("Friends (\(friends.count))")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if !searchTerm.isEmpty, filteredFriends.isEmpty {
                ContentUnavailableView.search(text: searchTerm)
            }
        }
        .sensoryFeedback(.success, trigger: isRefreshing) { oldValue, newValue in
            oldValue && !newValue
        }
        .sensoryFeedback(.success, trigger: friendEnvironmentModel.friends) { oldValue, newValue in
            newValue.count > oldValue.count
        }
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .task(id: refreshId) { [refreshId] in
            guard resultId != refreshId else { return }
            await loadFriends()
            resultId = refreshId
        }
        .toolbar {
            toolbarContent
        }
        .alertError($alertError)
        #if !targetEnvironment(macCatalyst)
            .refreshable {
                refreshId += 1
            }
        #endif
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if friendEnvironmentModel.hasNoFriendStatus(friend: profile) {
                ProgressButton(
                    "Add friend",
                    systemImage: "person.fill.badge.plus",
                    action: { await friendEnvironmentModel.sendFriendRequest(receiver: profile.id) }
                )
                .labelStyle(.iconOnly)
                .imageScale(.large)
            }
        }
    }

    func refresh() async {
        isRefreshing = true
        await loadFriends()
        isRefreshing = false
    }

    func loadFriends() async {
        switch await repository.friend.getByUserId(
            userId: profile.id,
            status: Friend.Status.accepted
        ) {
        case let .success(friends):
            self.friends = friends
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to load friends' . Error: \(error) (\(#file):\(#line))")
        }
    }
}
