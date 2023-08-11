import SwiftUI

struct CurrentUserFriendsScreen: View {
    @Environment(ProfileManager.self) private var profileManager
    @Environment(FriendManager.self) private var friendManager
    @Environment(FeedbackManager.self) private var feedbackManager
    @Environment(NotificationManager.self) private var notificationManager
    @State private var friendToBeRemoved: Friend? {
        didSet {
            showRemoveFriendConfirmation = true
        }
    }

    @State private var showRemoveFriendConfirmation = false
    @State private var showUserSearchSheet = false
    @State private var searchTerm = ""

    var filteredFriends: [Friend] {
        if searchTerm.isEmpty {
            return friendManager.acceptedOrPendingFriends
        }
        return friendManager.acceptedOrPendingFriends.filter { friend in
            friend.getFriend(userId: profileManager.id).preferredName.contains(searchTerm)
        }
    }

    var body: some View {
        List {
            ForEach(filteredFriends) { friend in
                FriendListItemView(profile: friend.getFriend(userId: profileManager.profile.id)) {
                    HStack {
                        if friend.status == Friend.Status.pending {
                            Text("(\(friend.status.rawValue.capitalized))")
                                .font(.footnote)
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        if friend.isPending(userId: profileManager.profile.id) {
                            HStack(alignment: .center) {
                                Label("Remove friend request", systemSymbol: .personFillXmark)
                                    .imageScale(.large)
                                    .labelStyle(.iconOnly)
                                    .accessibilityAddTraits(.isButton)
                                    .onTapGesture {
                                        friendToBeRemoved = friend
                                    }
                                Label("Accept friend request", systemSymbol: .personBadgePlus)
                                    .imageScale(.large)
                                    .labelStyle(.iconOnly)
                                    .accessibilityAddTraits(.isButton)
                                    .onTapGesture { Task {
                                        await friendManager.updateFriendRequest(friend: friend, newStatus: .accepted)
                                    }
                                    }
                            }
                        }
                    }
                }
                .swipeActions {
                    Group {
                        if friend.isPending(userId: profileManager.profile.id) {
                            ProgressButton(
                                "Accept friend request",
                                systemSymbol: .personBadgePlus,
                                action: { await friendManager.updateFriendRequest(friend: friend, newStatus: .accepted)
                                }
                            )
                            .tint(.green)
                        }
                        Button(
                            "Delete",
                            systemSymbol: .personFillXmark,
                            role: .destructive,
                            action: { friendToBeRemoved = friend }
                        )
                        ProgressButton(
                            "Block",
                            systemSymbol: .person2Slash,
                            action: { await friendManager.updateFriendRequest(friend: friend, newStatus: .blocked) }
                        )
                    }.imageScale(.large)
                }
                .contextMenu {
                    Button(
                        "Delete",
                        systemSymbol: .personFillXmark,
                        role: .destructive,
                        action: { friendToBeRemoved = friend }
                    )
                    ProgressButton(
                        "Block",
                        systemSymbol: .person2Slash,
                        action: { await friendManager.updateFriendRequest(friend: friend, newStatus: .blocked) }
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Friends (\(friendManager.friends.count))")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        #if !targetEnvironment(macCatalyst)
            .refreshable {
                await friendManager.refresh(withFeedback: true)
            }
        #endif
            .task {
                    await friendManager.refresh(withFeedback: false)
                    await notificationManager.markAllFriendRequestsAsRead()
                }
                .toolbar {
                    toolbarContent
                }
                .confirmationDialog(
                    """
                    Remove user from your friends, you will no longer be able to see each other's check-ins on your
                    activity feed nor be able to tag each other check-ins
                    """,
                    isPresented: $showRemoveFriendConfirmation,
                    titleVisibility: .visible,
                    presenting: friendToBeRemoved
                ) { presenting in
                    ProgressButton(
                        "Remove \(presenting.getFriend(userId: profileManager.id).preferredName) from friends",
                        role: .destructive,
                        action: {
                            await friendManager.removeFriendRequest(presenting)
                        }
                    )
                }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            RouterLink(
                "Show name tag or send friend request by QR code",
                systemSymbol: .qrcode,
                sheet: .nameTag(onSuccess: { profileId in
                    Task {
                        await friendManager.sendFriendRequest(receiver: profileId)
                    }
                })
            )
            .labelStyle(.iconOnly)
            .imageScale(.large)
            .popoverTip(NameTagTip())

            RouterLink("Add friend", systemSymbol: .plus, sheet: .userSheet(mode: .add, onSubmit: {
                feedbackManager.toggle(.success("Friend Request Sent!"))
            }))
            .labelStyle(.iconOnly)
            .imageScale(.large)
        }
    }
}
