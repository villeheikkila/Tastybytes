import Components
import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct CurrentUserFriendsScreen: View {
    @Environment(Router.self) private var router
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @State private var friendToBeRemoved: Friend?
    @State private var showUserSearchSheet = false
    @State private var searchTerm = ""

    let showToolbar: Bool

    var filteredFriends: [Friend] {
        friendEnvironmentModel.acceptedOrPendingFriends.filter { friend in
            searchTerm.isEmpty
                || friend.getFriend(userId: profileEnvironmentModel.id).preferredName.lowercased()
                .contains(searchTerm.lowercased())
        }
    }

    var body: some View {
        List(filteredFriends) { friend in
            CurrentUserFriendListRow(friend: friend)
        }
        .listStyle(.plain)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .refreshable {
            await friendEnvironmentModel.refresh(withHaptics: true)
        }
        .sensoryFeedback(.success, trigger: friendEnvironmentModel.isRefreshing) { oldValue, newValue in
            oldValue && !newValue
        }
        .overlay {
            if friendEnvironmentModel.state == .populated {
                if friendEnvironmentModel.friends.isEmpty {
                    ContentUnavailableView {
                        Label("friends.contentUnavailable.noFriends", systemImage: "person.3")
                    }
                } else if !searchTerm.isEmpty, filteredFriends.isEmpty {
                    ContentUnavailableView.search(text: searchTerm)
                }
            } else {
                ScreenStateOverlayView(state: friendEnvironmentModel.state, errorDescription: "") {
                    await friendEnvironmentModel.refresh()
                }
            }
        }
        .navigationTitle("friends.title \(friendEnvironmentModel.friends.count.formatted())")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if showToolbar {
                toolbarContent
            }
        }
        .initialTask {
            await friendEnvironmentModel.refresh()
        }
        .task {
            await notificationEnvironmentModel.markAllFriendRequestsAsRead()
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button(
                "friends.toolbar.showNameTag",
                systemImage: "qrcode",
                action: { router.openRootSheet(.nameTag(onSuccess: { profileId in
                    Task {
                        await friendEnvironmentModel.sendFriendRequest(receiver: profileId)
                    }
                })) }
            )
            .labelStyle(.iconOnly)
            .imageScale(.large)
            .popoverTip(NameTagTip())

            Button(
                "friends.add.label", systemImage: "plus",
                action: { router.openRootSheet(.userSheet(
                    mode: .add,
                    onSubmit: {
                        feedbackEnvironmentModel.toggle(.success("friends.add.success"))
                    }
                )) }
            )
            .labelStyle(.iconOnly)
            .imageScale(.large)
        }
    }
}

@MainActor
struct CurrentUserFriendListRow: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @State private var showFriendDeleteConfirmation = false

    let friend: Friend

    var body: some View {
        FriendListItemView(profile: friend.getFriend(userId: profileEnvironmentModel.profile.id)) {
            HStack {
                if friend.status == .pending {
                    Text(friend.status.label)
                        .font(.footnote)
                        .foregroundColor(.primary)
                }
                Spacer()
                if friend.isPending(userId: profileEnvironmentModel.profile.id) {
                    HStack(alignment: .center) {
                        Label("friends.action.removeFriendRequest.label", systemImage: "person.fill.xmark")
                            .imageScale(.large)
                            .labelStyle(.iconOnly)
                            .accessibilityAddTraits(.isButton)
                            .onTapGesture {
                                showFriendDeleteConfirmation = true
                            }
                        Label("friends.acceptRequest.label", systemImage: "person.badge.plus")
                            .imageScale(.large)
                            .labelStyle(.iconOnly)
                            .accessibilityAddTraits(.isButton)
                            .onTapGesture {
                                Task {
                                    await friendEnvironmentModel.updateFriendRequest(
                                        friend: friend,
                                        newStatus: .accepted
                                    )
                                }
                            }
                    }
                }
            }
        }
        .swipeActions {
            Group {
                if friend.isPending(userId: profileEnvironmentModel.profile.id) {
                    ProgressButton(
                        "friends.acceptRequest.label",
                        systemImage: "person.badge.plus",
                        action: {
                            await friendEnvironmentModel.updateFriendRequest(
                                friend: friend,
                                newStatus: .accepted
                            )
                        }
                    )
                    .tint(.green)
                }
                deleteFriendButton
                blockFriendButton
            }.imageScale(.large)
        }
        .contextMenu {
            deleteFriendButton
            blockFriendButton
        }
        .confirmationDialog("friend.delete.confirmation.title",
                            isPresented: $showFriendDeleteConfirmation,
                            titleVisibility: .visible,
                            presenting: friend)
        { presenting in
            ProgressButton(
                "friend.delete.confirmation.label \(presenting.getFriend(userId: profileEnvironmentModel.id).preferredName)",
                role: .destructive,
                action: {
                    await friendEnvironmentModel.removeFriendRequest(presenting)
                }
            )
        }
    }

    var deleteFriendButton: some View {
        Button(
            "labels.delete",
            systemImage: "person.fill.xmark",
            role: .destructive,
            action: { showFriendDeleteConfirmation = true }
        )
    }

    var blockFriendButton: some View {
        ProgressButton(
            "friends.block.label",
            systemImage: "person.2.slash",
            action: {
                await friendEnvironmentModel.updateFriendRequest(friend: friend, newStatus: .blocked)
            }
        )
    }
}
