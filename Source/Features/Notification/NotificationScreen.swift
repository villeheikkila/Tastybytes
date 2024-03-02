import Components
import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct NotificationScreen: View {
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var filter: NotificationType?
    @Binding var scrollToTop: Int

    var filteredNotifications: [Models.Notification] {
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

    var showContentUnavailableView: Bool {
        notificationEnvironmentModel.isInitialized && filteredNotifications.isEmpty && !notificationEnvironmentModel
            .isRefreshing
    }

    var body: some View {
        @Bindable var notificationEnvironmentModel = notificationEnvironmentModel
        ScrollViewReader { scrollProxy in
            List {
                ForEach(filteredNotifications) { notification in
                    notification.notificationView
                        .listRowBackground(notification.seenAt == nil ? Color(.systemGray5) : nil)
                }
                .onDelete(perform: { index in Task {
                    await notificationEnvironmentModel.deleteFromIndex(at: index)
                } })
            }
            .listStyle(.plain)
            .refreshable {
                notificationEnvironmentModel.refresh(reset: true, withHaptics: true)
            }
            .background {
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
            .sensoryFeedback(.success, trigger: notificationEnvironmentModel.isRefreshing) { oldValue, newValue in
                oldValue && !newValue
            }
            .onChange(of: scrollToTop) {
                withAnimation {
                    filter = nil
                    if let first = filteredNotifications.first {
                        scrollProxy.scrollTo(first.id, anchor: .top)
                    }
                }
            }
        }
        .onAppear {
            notificationEnvironmentModel.refresh()
        }
        .navigationTitle(filter?.label ?? "notifications.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Menu {
                ProgressButton("notifications.markAsRead.label", systemImage: "envelope.open", action: {
                    feedbackEnvironmentModel.trigger(.impact(intensity: .low))
                    await notificationEnvironmentModel.markAllAsRead()
                })
                ProgressButton("notifications.deleteAll.label", systemImage: "trash", action: {
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
            ForEach(NotificationType.allCases) { type in
                Button(type.label, systemImage: type.systemImage) {
                    withAnimation {
                        filter = type
                    }
                }
            }
        }
    }
}

extension Models.Notification {
    @ViewBuilder
    var notificationView: some View {
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

extension NotificationType {
    var contentUnavailableViewProps: ContentUnavailableViewProps {
        switch self {
        case .checkInComment:
            ContentUnavailableViewProps(
                title: "notification.checkInComments.empty.title",
                description: "",
                icon: "tray"
            )
        case .checkInReaction:
            ContentUnavailableViewProps(
                title: "notification.checkInReactions.empty.title",
                description: "",
                icon: "tray"
            )
        case .friendRequest:
            ContentUnavailableViewProps(
                title: "notification.friendRequests.empty.title",
                description: "",
                icon: "tray"
            )
        case .message:
            ContentUnavailableViewProps(
                title: "notification.messages.empty.title",
                description: "",
                icon: "tray"
            )
        case .taggedCheckIn:
            ContentUnavailableViewProps(
                title: "notification.checkInTags.empty.title",
                description: "",
                icon: "tray"
            )
        }
    }
}

struct ContentUnavailableViewProps {
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let icon: String
}

public extension NotificationType {
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

struct DefaultScrollContentBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        if colorScheme == .dark {
            content.scrollContentBackground(.hidden)
        } else {
            content.scrollContentBackground(.visible)
        }
    }
}

extension View {
    func defaultScrollContentBackground() -> some View {
        modifier(DefaultScrollContentBackground())
    }
}
