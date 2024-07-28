import Components

import Models
import SwiftUI

struct CurrentUserFriendsScreen: View {
    @Environment(ProfileModel.self) private var profileModel
    @Environment(Router.self) private var router
    @Environment(NotificationModel.self) private var notificationModel
    @State private var friendToBeRemoved: Friend?
    @State private var showUserSearchSheet = false
    @State private var searchTerm = ""

    let showToolbar: Bool

    private var filteredFriends: [Friend.Saved] {
        if searchTerm.isEmpty {
            profileModel.acceptedOrPendingFriends
        } else {
            profileModel.acceptedOrPendingFriends.filter {
                $0.getFriend(userId: profileModel.id).preferredName.localizedCaseInsensitiveContains(searchTerm)
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
            await profileModel.refreshFriends(withHaptics: true)
        }
        .overlay {
            if profileModel.friends.isEmpty {
                ContentUnavailableView {
                    Label("friends.contentUnavailable.noFriends", systemImage: "person.3")
                }
            } else if !searchTerm.isEmpty, filteredFriends.isEmpty {
                ContentUnavailableView.search(text: searchTerm)
            }
        }
        .navigationTitle("friends.title \(profileModel.friends.count.formatted())")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if showToolbar {
                toolbarContent
            }
        }
        .initialTask {
            await profileModel.refreshFriends()
        }
        .task {
            await notificationModel.markAllFriendRequestsAsRead()
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            RouterLink(
                "friends.toolbar.showNameTag",
                systemImage: "qrcode",
                open: .sheet(.nameTag(onSuccess: { profileId in
                    Task {
                        await profileModel.sendFriendRequest(receiver: profileId)
                    }
                }))
            )
            .labelStyle(.iconOnly)
            .imageScale(.large)
            .popoverTip(NameTagTip())

            if profileModel.hasPermission(.canSendFriendRequests) {
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
    @Environment(ProfileModel.self) private var profileModel
    @State private var showFriendDeleteConfirmation = false

    let friend: Friend.Saved

    var body: some View {
        FriendListItemView(profile: friend.getFriend(userId: profileModel.profile.id)) {
            HStack {
                if friend.status == .pending {
                    Text(friend.status.label)
                        .font(.footnote)
                        .foregroundColor(.primary)
                }
                Spacer()
                if friend.isPending(userId: profileModel.profile.id) {
                    HStack(alignment: .center) {
                        Button("friends.action.removeFriendRequest.label", systemImage: "person.fill.xmark", action: {
                            showFriendDeleteConfirmation = true
                        })
                        AsyncButton("friends.acceptRequest.label", systemImage: "person.badge.plus", action: {
                            await profileModel.updateFriendRequest(friend: friend, newStatus: .accepted)
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
                if friend.isPending(userId: profileModel.profile.id) {
                    AsyncButton(
                        "friends.acceptRequest.label",
                        systemImage: "person.badge.plus",
                        action: {
                            await profileModel.updateFriendRequest(
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
                "friend.delete.confirmation.label \(presenting.getFriend(userId: profileModel.id).preferredName)",
                role: .destructive,
                action: {
                    await profileModel.removeFriendRequest(presenting)
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
                await profileModel.updateFriendRequest(friend: friend, newStatus: .blocked)
            }
        )
    }
}
