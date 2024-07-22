import Components
import EnvironmentModels
import Models
import SwiftUI

struct CurrentUserFriendsScreen: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(Router.self) private var router
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @State private var friendToBeRemoved: Friend?
    @State private var showUserSearchSheet = false
    @State private var searchTerm = ""

    let showToolbar: Bool

    private var filteredFriends: [Friend] {
        if searchTerm.isEmpty {
            friendEnvironmentModel.acceptedOrPendingFriends
        } else {
            friendEnvironmentModel.acceptedOrPendingFriends.filter {
                $0.getFriend(userId: profileEnvironmentModel.id).preferredName.localizedCaseInsensitiveContains(searchTerm)
            }
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
            if friendEnvironmentModel.state.isPopulated {
                if friendEnvironmentModel.friends.isEmpty {
                    ContentUnavailableView {
                        Label("friends.contentUnavailable.noFriends", systemImage: "person.3")
                    }
                } else if !searchTerm.isEmpty, filteredFriends.isEmpty {
                    ContentUnavailableView.search(text: searchTerm)
                }
            } else {
                ScreenStateOverlayView(state: friendEnvironmentModel.state) {
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
            RouterLink(
                "friends.toolbar.showNameTag",
                systemImage: "qrcode",
                open: .sheet(.nameTag(onSuccess: { profileId in
                    Task {
                        await friendEnvironmentModel.sendFriendRequest(receiver: profileId)
                    }
                }))
            )
            .labelStyle(.iconOnly)
            .imageScale(.large)
            .popoverTip(NameTagTip())

            if profileEnvironmentModel.hasPermission(.canSendFriendRequests) {
                RouterLink(
                    "friends.add.label", systemImage: "plus",
                    open: .sheet(.profilePicker(
                        mode: .add,
                        onSubmit: {
                            router.open(.toast(.success("friends.add.success")))
                        }
                    ))
                )
                .labelStyle(.iconOnly)
                .imageScale(.large)
            }
        }
    }
}

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
                        Button("friends.action.removeFriendRequest.label", systemImage: "person.fill.xmark", action: {
                            showFriendDeleteConfirmation = true
                        })
                        AsyncButton("friends.acceptRequest.label", systemImage: "person.badge.plus", action: {
                            await friendEnvironmentModel.updateFriendRequest(friend: friend, newStatus: .accepted)
                        })
                    }
                    .buttonStyle(.plain)
                    .imageScale(.large)
                    .labelStyle(.iconOnly)
                }
            }
        }
        .swipeActions {
            Group {
                if friend.isPending(userId: profileEnvironmentModel.profile.id) {
                    AsyncButton(
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
            AsyncButton(
                "friend.delete.confirmation.label \(presenting.getFriend(userId: profileEnvironmentModel.id).preferredName)",
                role: .destructive,
                action: {
                    await friendEnvironmentModel.removeFriendRequest(presenting)
                }
            )
        }
    }

    private var deleteFriendButton: some View {
        Button(
            "labels.delete",
            systemImage: "person.fill.xmark",
            action: { showFriendDeleteConfirmation = true }
        )
        .tint(.red)
    }

    private var blockFriendButton: some View {
        AsyncButton(
            "friends.block.label",
            systemImage: "person.2.slash",
            action: {
                await friendEnvironmentModel.updateFriendRequest(friend: friend, newStatus: .blocked)
            }
        )
    }
}
