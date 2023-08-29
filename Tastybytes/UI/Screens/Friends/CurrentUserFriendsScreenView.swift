import EnvironmentModels
import Models
import SwiftUI

struct CurrentUserFriendsScreen: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
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
            return friendEnvironmentModel.acceptedOrPendingFriends
        }
        return friendEnvironmentModel.acceptedOrPendingFriends.filter { friend in
            friend.getFriend(userId: profileEnvironmentModel.id).preferredName.contains(searchTerm)
        }
    }

    var body: some View {
        List {
            ForEach(filteredFriends) { friend in
                FriendListItemView(profile: friend.getFriend(userId: profileEnvironmentModel.profile.id)) {
                    HStack {
                        if friend.status == Friend.Status.pending {
                            Text("(\(friend.status.rawValue.capitalized))")
                                .font(.footnote)
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        if friend.isPending(userId: profileEnvironmentModel.profile.id) {
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
                                "Accept friend request",
                                systemSymbol: .personBadgePlus,
                                action: {
                                    await friendEnvironmentModel.updateFriendRequest(
                                        friend: friend,
                                        newStatus: .accepted
                                    )
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
                            action: {
                                await friendEnvironmentModel.updateFriendRequest(friend: friend, newStatus: .blocked)
                            }
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
                        action: { await friendEnvironmentModel.updateFriendRequest(friend: friend, newStatus: .blocked)
                        }
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Friends (\(friendEnvironmentModel.friends.count))")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        #if !targetEnvironment(macCatalyst)
            .refreshable {
                await friendEnvironmentModel.refresh(withFeedback: true)
            }
        #endif
            .task {
                    await friendEnvironmentModel.refresh(withFeedback: false)
                    await notificationEnvironmentModel.markAllFriendRequestsAsRead()
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
                        "Remove \(presenting.getFriend(userId: profileEnvironmentModel.id).preferredName) from friends",
                        role: .destructive,
                        action: {
                            await friendEnvironmentModel.removeFriendRequest(presenting)
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
                        await friendEnvironmentModel.sendFriendRequest(receiver: profileId)
                    }
                })
            )
            .labelStyle(.iconOnly)
            .imageScale(.large)
            .popoverTip(NameTagTip())

            RouterLink("Add friend", systemSymbol: .plus, sheet: .userSheet(mode: .add, onSubmit: {
                feedbackEnvironmentModel.toggle(.success("Friend Request Sent!"))
            }))
            .labelStyle(.iconOnly)
            .imageScale(.large)
        }
    }
}
