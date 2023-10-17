import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct FriendsScreen: View {
    private let logger = Logger(category: "FriendsScreen")
    @Environment(\.repository) private var repository
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var friends: [Friend]
    @State private var searchTerm = ""

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
            if !searchTerm.isEmpty && filteredFriends.isEmpty {
                ContentUnavailableView.search(text: searchTerm)
            }
        }
        .sensoryFeedback(.success, trigger: friendEnvironmentModel.friends)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        #if !targetEnvironment(macCatalyst)
            .refreshable {
                await loadFriends()
            }
        #endif
            .task {
                    if friends.isEmpty {
                        await loadFriends()
                    }
                }
                .toolbar {
                    toolbarContent
                }
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

    func loadFriends(withHaptics: Bool = false) async {
        if withHaptics {
            feedbackEnvironmentModel.trigger(.impact(intensity: .low))
        }
        switch await repository.friend.getByUserId(
            userId: profile.id,
            status: Friend.Status.accepted
        ) {
        case let .success(friends):
            self.friends = friends
            if withHaptics {
                feedbackEnvironmentModel.trigger(.impact(intensity: .high))
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("Failed to load friends' . Error: \(error) (\(#file):\(#line))")
        }
    }
}
