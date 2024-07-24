import Components
import EnvironmentModels
import Models
import SwiftUI

struct NotificationScreen: View {
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var filter: Models.Notification.Kind?

    private var filteredNotifications: [Models.Notification.Joined] {
        notificationEnvironmentModel.notifications.filter { notification in
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
        filteredNotifications.isEmpty && !notificationEnvironmentModel.isRefreshing
    }

    var body: some View {
        List {
            ForEach(filteredNotifications) { notification in
                notification.view
                    .buttonStyle(.plain)
                    .listRowBackground(notification.seenAt == nil ? Color(.systemGray5) : nil)
            }
            .onDelete { index in
                Task {
                    await notificationEnvironmentModel.deleteFromIndex(at: index)
                }
            }
        }
        .listStyle(.plain)
        .routerLinkMode(.button)
        .refreshable {
            notificationEnvironmentModel.refresh(reset: true, withHaptics: true)
        }
        .overlay {
            if notificationEnvironmentModel.state.isPopulated {
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
            } else {
                ScreenStateOverlayView(state: notificationEnvironmentModel.state) {
                    notificationEnvironmentModel.refresh(reset: true, withHaptics: true)
                }
            }
        }
        .sensoryFeedback(.success, trigger: notificationEnvironmentModel.isRefreshing) { oldValue, newValue in
            oldValue && !newValue
        }
        .onAppear {
            notificationEnvironmentModel.refresh()
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
                    feedbackEnvironmentModel.trigger(.impact(intensity: .low))
                    await notificationEnvironmentModel.markAllAsRead()
                })
                AsyncButton("notifications.deleteAll.label", systemImage: "trash", action: {
                    feedbackEnvironmentModel.trigger(.impact(intensity: .low))
                    await notificationEnvironmentModel.deleteAll()
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
