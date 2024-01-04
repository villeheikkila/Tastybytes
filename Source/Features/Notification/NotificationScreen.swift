import Components
import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct NotificationScreen: View {
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Binding var scrollToTop: Int
    @State var filter: NotificationType?

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
                        .listRowSeparator(.hidden)
                        .listRowBackground(notification.seenAt == nil ? nil : Color(.systemGray5))
                }
                .onDelete(perform: { index in Task {
                    await notificationEnvironmentModel.deleteFromIndex(at: index)
                } })
            }
            .sensoryFeedback(.success, trigger: notificationEnvironmentModel.isRefreshing) { oldValue, newValue in
                oldValue && !newValue
            }
            .overlay {
                ContentUnavailableView {
                    Label(
                        filter?.contentUnavailableViewProps.title ?? "You have no notifications",
                        systemImage: filter?.contentUnavailableViewProps.icon ?? "tray"
                    )
                } description: {
                    Text(filter?.contentUnavailableViewProps.description ?? "")
                }
                .opacity(showContentUnavailableView ? 1 : 0)
            }
            #if !targetEnvironment(macCatalyst)
            .refreshable {
                notificationEnvironmentModel.refresh(reset: true, withHaptics: true)
            }
            #endif
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
        .dismissSplashScreen()
        .navigationTitle(filter?.label ?? "Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Menu {
                ProgressButton("Mark all read", systemImage: "envelope.open", action: {
                    feedbackEnvironmentModel.trigger(.impact(intensity: .low))
                    await notificationEnvironmentModel.markAllAsRead()
                })
                ProgressButton("Delete all", systemImage: "trash", action: {
                    feedbackEnvironmentModel.trigger(.impact(intensity: .low))
                    await notificationEnvironmentModel.deleteAll()
                })
            } label: {
                Label("Options menu", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
            }
        }
        ToolbarTitleMenu {
            Button {
                withAnimation {
                    filter = nil
                }
            } label: {
                Label("Show All", systemImage: "bell.fill")
            }
            Divider()
            ForEach(NotificationType.allCases) { type in
                Button {
                    withAnimation {
                        filter = type
                    }
                } label: {
                    Label(type.label, systemImage: type.systemImage)
                }
            }
        }
    }
}

extension Models.Notification {
    @ViewBuilder
    var notificationView: some View {
        switch self.content {
        case let .message(message):
            MessageNotificationView(message: message)
        case let .friendRequest(friendRequest):
            FriendRequestNotificationView(friend: friendRequest)
        case let .taggedCheckIn(taggedCheckIn):
            TaggedInCheckInNotificationView(checkIn: taggedCheckIn)
        case let .checkInComment(checkInComment):
            CheckInCommentNotificationView(checkInComment: checkInComment)
        case let .checkInReaction(checkInReaction):
            CheckInReactionNotificationView(checkInReaction: checkInReaction)
        }
    }
}

extension NotificationType {
    var contentUnavailableViewProps: ContentUnavailableViewProps {
        switch self {
        case .checkInComment:
            ContentUnavailableViewProps(
                title: "No check-in comment notifications",
                description: "",
                icon: "tray"
            )
        case .checkInReaction:
            ContentUnavailableViewProps(
                title: "No check-in reaction notifications",
                description: "",
                icon: "tray"
            )
        case .friendRequest:
            ContentUnavailableViewProps(
                title: "No friend request notifications",
                description: "",
                icon: "tray"
            )
        case .message:
            ContentUnavailableViewProps(
                title: "No messages",
                description: "",
                icon: "tray"
            )
        case .taggedCheckIn:
            ContentUnavailableViewProps(
                title: "No check-in tag notifications",
                description: "",
                icon: "tray"
            )
        }
    }
}

struct ContentUnavailableViewProps {
    let title: String
    let description: String
    let icon: String
}
