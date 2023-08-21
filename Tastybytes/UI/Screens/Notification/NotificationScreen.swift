import Models
import SwiftUI

struct NotificationScreen: View {
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(SplashScreenManager.self) private var splashScreenManager
    @Environment(FeedbackManager.self) private var feedbackManager
    @Binding var scrollToTop: Int

    @State var filter: NotificationType?

    var filteredNotifications: [Models.Notification] {
        notificationManager.notifications.filter { notification in
            if self.filter == nil {
                return true
            } else {
                return switch notification.content {
                case .checkInReaction:
                    self.filter == .checkInReaction
                case .friendRequest:
                    self.filter == .friendRequest
                case .message:
                    self.filter == .message
                case .checkInComment:
                    self.filter == .checkInComment
                case .taggedCheckIn:
                    self.filter == .taggedCheckIn
                }
            }
        }
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            List {
                ForEach(filteredNotifications) { notification in
                    HStack {
                        switch notification.content {
                        case let .message(message):
                            MessageNotificationView(message: message)
                                .accessibilityAddTraits(.isButton)
                                .onTapGesture {
                                    Task { await notificationManager.markAsRead(notification) }
                                }
                        case let .friendRequest(friendRequest):
                            FriendRequestNotificationView(friend: friendRequest)
                        case let .taggedCheckIn(taggedCheckIn):
                            TaggedInCheckInNotificationView(checkIn: taggedCheckIn)
                        case let .checkInComment(checkInComment):
                            CheckInCommentNotificationView(checkInComment: checkInComment)
                        case let .checkInReaction(checkInReaction):
                            CheckInReactionNotificationView(checkInReaction: checkInReaction)
                        }
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(notification.seenAt == nil ? nil : Color(.systemGray5))
                }
                .onDelete(perform: { index in Task {
                    await notificationManager.deleteFromIndex(at: index)
                } })
            }
            #if !targetEnvironment(macCatalyst)
            .refreshable {
                await notificationManager.refresh(reset: true, withFeedback: true)
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
        .task {
            await notificationManager.refresh(reset: true)
        }
        .task {
            await splashScreenManager.dismiss()
        }
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
                ProgressButton("Mark all read", systemSymbol: .envelopeOpen, action: {
                    feedbackManager.trigger(.impact(intensity: .low))
                    await notificationManager.markAllAsRead()
                })
                ProgressButton("Delete all", systemSymbol: .trash, action: {
                    feedbackManager.trigger(.impact(intensity: .low))
                    await notificationManager.deleteAll()
                })
            } label: {
                Label("Options menu", systemSymbol: .ellipsis)
                    .labelStyle(.iconOnly)
            }
        }
        ToolbarTitleMenu {
            Button {
                withAnimation {
                    filter = nil
                }
            } label: {
                Label("Show All", systemSymbol: .bellFill)
            }
            Divider()
            ForEach(NotificationType.allCases) { type in
                Button {
                    withAnimation {
                        filter = type
                    }
                } label: {
                    Label(type.label, systemSymbol: type.systemSymbol)
                }
            }
        }
    }
}
