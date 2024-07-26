
import SwiftUI

enum NotificationDeliveryType: CaseIterable {
    case disabled
    case inApp
    case pushNotification

    var label: LocalizedStringKey {
        switch self {
        case .disabled:
            "notification.deliveryType.disabled"
        case .inApp:
            "notification.deliveryType.disabled.inApp"
        case .pushNotification:
            "notification.deliveryType.push"
        }
    }
}

struct NotificationSettingsScreen: View {
    @Environment(ProfileModel.self) private var profileModel
    @Environment(NotificationModel.self) private var notificationModel
    @State private var initialValuesLoaded = false
    @State private var reactioNotificationDeliveryType: NotificationDeliveryType = .disabled
    @State private var checkInNotificationDeliveryType: NotificationDeliveryType = .disabled
    @State private var checkInCommentNotificationsDeliveryType: NotificationDeliveryType = .disabled
    @State private var friendRequestNotificationDeliveryType: NotificationDeliveryType = .disabled

    var body: some View {
        Form {
            Section {
                NotificationDeliveryTypePickerView(
                    notificationDeliveryType: $reactioNotificationDeliveryType,
                    title: "notifications.settings.reactions.label",
                    subtitle: "notifications.settings.reactions.subtitle"
                )
                NotificationDeliveryTypePickerView(
                    notificationDeliveryType: $checkInCommentNotificationsDeliveryType,
                    title: "notifications.settings.comments.label",
                    subtitle: "notifications.settings.comments.subtitle"
                )
                NotificationDeliveryTypePickerView(
                    notificationDeliveryType: $checkInNotificationDeliveryType,
                    title: "notifications.settings.checkIns.label",
                    subtitle: "notifications.settings.checkIns.subtitle"
                )
                NotificationDeliveryTypePickerView(
                    notificationDeliveryType: $friendRequestNotificationDeliveryType,
                    title: "notifications.settings.friendRequest.label",
                    subtitle: "notifications.settings.friendRequest.subtitle"
                )
            }
            if let settingsUrl = URL(string: UIApplication.openNotificationSettingsURLString) {
                Section {
                    Link("notitifications.systemSettings.link", destination: settingsUrl)
                } header: {
                    Text("notitifications.systemSettings.title")
                } footer: {
                    Text("notitifications.systemSettings.description")
                }
            }
        }
        .navigationTitle("settings.notifications.title")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: reactioNotificationDeliveryType) { _, newState in
            Task {
                await notificationModel
                    .updatePushNotificationSettingsForDevice(sendReactionNotifications: newState ==
                        .pushNotification)
                await profileModel
                    .updateNotificationSettings(sendReactionNotifications: newState != .disabled)
            }
        }
        .onChange(of: checkInNotificationDeliveryType) { _, newState in
            Task {
                await notificationModel
                    .updatePushNotificationSettingsForDevice(sendTaggedCheckInNotifications: newState ==
                        .pushNotification)
                await profileModel
                    .updateNotificationSettings(sendTaggedCheckInNotifications: newState != .disabled)
            }
        }
        .onChange(of: friendRequestNotificationDeliveryType) { _, newState in
            Task {
                await notificationModel
                    .updatePushNotificationSettingsForDevice(sendFriendRequestNotifications: newState ==
                        .pushNotification)
                await profileModel
                    .updateNotificationSettings(sendFriendRequestNotifications: newState != .disabled)
            }
        }
        .onChange(of: checkInCommentNotificationsDeliveryType) { _, newState in
            Task {
                await notificationModel
                    .updatePushNotificationSettingsForDevice(sendCheckInCommentNotifications: newState ==
                        .pushNotification)
                await profileModel
                    .updateNotificationSettings(sendCheckInCommentNotifications: newState != .disabled)
            }
        }
        .task {
            if !initialValuesLoaded {
                reactioNotificationDeliveryType = profileModel
                    .reactionNotifications ? notificationModel
                    .pushNotificationSettings?
                    .sendReactionNotifications ?? false ? .pushNotification : .inApp : .disabled
                checkInNotificationDeliveryType = profileModel
                    .checkInTagNotifications ? notificationModel
                    .pushNotificationSettings?
                    .sendTaggedCheckInNotifications ?? false ? .pushNotification : .inApp :
                    .disabled
                friendRequestNotificationDeliveryType = profileModel
                    .friendRequestNotifications ? notificationModel
                    .pushNotificationSettings?
                    .sendFriendRequestNotifications ?? false ? .pushNotification : .inApp :
                    .disabled
                checkInCommentNotificationsDeliveryType = profileModel
                    .sendCommentNotifications ? notificationModel
                    .pushNotificationSettings?
                    .sendCheckInCommentNotifications ?? false ? .pushNotification : .inApp :
                    .disabled
            }
            initialValuesLoaded = true
        }
    }
}

struct NotificationDeliveryTypePickerView: View {
    @Binding var notificationDeliveryType: NotificationDeliveryType

    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey?

    var body: some View {
        Picker(selection: $notificationDeliveryType) {
            ForEach(NotificationDeliveryType.allCases, id: \.self) { messageType in
                Text(messageType.label).tag(messageType)
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }.pickerStyle(.navigationLink)
    }
}
