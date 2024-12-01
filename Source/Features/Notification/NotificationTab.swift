import Components

import Models
import SwiftUI

struct NotificationTab: View {
    @Environment(ProfileModel.self) private var profileModel
    @Environment(FeedbackModel.self) private var feedbackModel
    @State private var filter: Models.Notification.Kind?

    private var filteredNotifications: [Models.Notification.Joined] {
        profileModel.notifications.filter { notification in
            if filter == nil {
                return true
            }
            return switch notification.content {
            case .checkInReaction:
                filter == .checkInReaction
            case .friendRequest:
                filter == .friendRequest
            case .message:
                filter == .message
            case .checkInComment:
                filter == .checkInComment
            case .taggedCheckIn:
                filter == .taggedCheckIn
            }
        }
    }

    private var showContentUnavailableView: Bool {
        filteredNotifications.isEmpty && !profileModel.isRefreshingNotifications
    }

    var body: some View {
        List {
            ForEach(filteredNotifications) { notification in
                Section {
                    notification.view
                }
                .buttonStyle(.plain)
                .listRowBackground(notification.seenAt == nil ? Color(.systemGray5) : nil)
                .contextMenu {
                    AsyncButton(
                        notification.isRead ? "notification.markAsUnread" : "notification.markAsRead",
                        systemImage: notification.isRead ? "envelope.open" : "envelope"
                    ) {
                        if notification.isRead {
                            await profileModel.notificationMarkAsUnread(notification)
                        } else {
                            await profileModel.notificationMarkAsRead(notification)
                        }
                    }
                    AsyncButton("labels.delete", systemImage: "trash", role: .destructive) {
                        await profileModel.notificationDelete(id: notification.id)
                    }
                }
            }
            .onDelete { index in
                Task {
                    guard let i = index.first, let notification = profileModel.notifications[safe: i] else { return }
                    await profileModel.notificationDelete(id: notification.id)
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(8)
        .routerLinkMode(.button)
        .animation(.default, value: profileModel.notifications)
        .refreshable {
            profileModel.refreshNotifications(reset: true, withHaptics: true)
        }
        .overlay {
            if showContentUnavailableView {
                ContentUnavailableView {
                    Label(
                        filter?.contentUnavailableViewProps.title ?? "notifications.empty.label",
                        systemImage: filter?.contentUnavailableViewProps.icon ?? "tray"
                    )
                } description: {
                    if let description = filter?.contentUnavailableViewProps.description {
                        Text(description)
                    }
                }
            }
        }
        .sensoryFeedback(.success, trigger: profileModel.isRefreshingNotifications) { oldValue, newValue in
            oldValue && !newValue
        }
        .onAppear {
            profileModel.refreshNotifications()
        }
        .navigationTitle(filter?.label ?? "notifications.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Menu {
                AsyncButton("notifications.markAsRead.label", systemImage: "envelope.open", action: {
                    feedbackModel.trigger(.impact(intensity: .low))
                    await profileModel.markAllAsRead()
                })
                AsyncButton("notifications.deleteAll.label", systemImage: "trash", action: {
                    feedbackModel.trigger(.impact(intensity: .low))
                    await profileModel.deleteAllNotifications()
                })
            } label: {
                Label("labels.menu", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
            }
        }
        ToolbarTitleMenu {
            Button {
                withAnimation {
                    filter = nil
                }
            } label: {
                Label("labels.showAll", systemImage: "bell.fill")
            }
            Divider()
            ForEach(Notification.Kind.allCases) { type in
                Button(type.label, systemImage: type.systemImage) {
                    withAnimation {
                        filter = type
                    }
                }
            }
        }
    }
}

extension Models.Notification.Joined {
    @ViewBuilder
    var view: some View {
        switch content {
        case let .message(message):
            MessageNotificationView(message: message)
        case let .friendRequest(friendRequest):
            FriendRequestNotificationView(friend: friendRequest, createdAt: createdAt, seenAt: seenAt)
        case let .taggedCheckIn(taggedCheckIn):
            TaggedInCheckInNotificationView(checkIn: taggedCheckIn, createdAt: createdAt, seenAt: seenAt)
        case let .checkInComment(checkInComment):
            CheckInCommentNotificationView(checkInComment: checkInComment, createdAt: createdAt, seenAt: seenAt)
        case let .checkInReaction(checkInReaction):
            CheckInReactionNotificationView(checkInReaction: checkInReaction, createdAt: createdAt, seenAt: seenAt)
        }
    }
}

extension Models.Notification.Kind {
    var contentUnavailableViewProps: ContentUnavailableViewProps {
        switch self {
        case .checkInComment:
            ContentUnavailableViewProps(
                title: "notification.checkInComments.empty.title",
                icon: "tray"
            )
        case .checkInReaction:
            ContentUnavailableViewProps(
                title: "notification.checkInReactions.empty.title",
                icon: "tray"
            )
        case .friendRequest:
            ContentUnavailableViewProps(
                title: "notification.friendRequests.empty.title",
                icon: "tray"
            )
        case .message:
            ContentUnavailableViewProps(
                title: "notification.messages.empty.title",
                icon: "tray"
            )
        case .taggedCheckIn:
            ContentUnavailableViewProps(
                title: "notification.checkInTags.empty.title",
                icon: "tray"
            )
        }
    }
}

struct ContentUnavailableViewProps {
    let title: LocalizedStringKey
    let description: LocalizedStringKey?
    let icon: String

    init(title: LocalizedStringKey, description: LocalizedStringKey? = nil, icon: String) {
        self.title = title
        self.description = description
        self.icon = icon
    }
}

public extension Models.Notification.Kind {
    var label: LocalizedStringKey {
        switch self {
        case .message:
            "notification.message.label"
        case .friendRequest:
            "notification.friendRequest.label"
        case .taggedCheckIn:
            "notification.taggedCheckIn.label"
        case .checkInReaction:
            "notification.checkInReaction.label"
        case .checkInComment:
            "notification.checkInComment.label"
        }
    }

    var systemImage: String {
        switch self {
        case .message:
            "bell"
        case .friendRequest:
            "person.badge.plus"
        case .taggedCheckIn:
            "tag"
        case .checkInReaction:
            "hand.thumbsup"
        case .checkInComment:
            "bubble.left"
        }
    }
}
