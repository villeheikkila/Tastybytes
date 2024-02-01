import EnvironmentModels
import SwiftUI

enum NotificationDeliveryType: String, CaseIterable {
    case disabled = "Disabled"
    case inApp = "In-App"
    case pushNotification = "Push "

    var label: String {
        rawValue
    }
}

struct NotificationSettingsScreen: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @State private var initialValuesLoaded = false
    @State private var reactioNotificationDeliveryType: NotificationDeliveryType = .disabled
    @State private var checkInNotificationDeliveryType: NotificationDeliveryType = .disabled
    @State private var checkInCommentNotificationsDeliveryType: NotificationDeliveryType = .disabled
    @State private var friendRequestNotificationDeliveryType: NotificationDeliveryType = .disabled

    var body: some View {
        Form {
            Section {
                NotificationDeliveryTypePicker(
                    notificationDeliveryType: $reactioNotificationDeliveryType,
                    title: "Reactions",
                    subtitle: "Show notification when someone reacts to your check-in"
                )
                NotificationDeliveryTypePicker(
                    notificationDeliveryType: $checkInCommentNotificationsDeliveryType,
                    title: "Comments",
                    subtitle: "Show notification when someone comments on your check-in"
                )
                NotificationDeliveryTypePicker(
                    notificationDeliveryType: $reactioNotificationDeliveryType,
                    title: "Check-ins",
                    subtitle: "Show notification when someone tags you in their check-in"
                )
                NotificationDeliveryTypePicker(
                    notificationDeliveryType: $friendRequestNotificationDeliveryType,
                    title: "Friend Requests",
                    subtitle: "Show notification when someone sends you a friend requests"
                )
            }
            if let settingsUrl = URL(string: UIApplication.openNotificationSettingsURLString) {
                Section {
                    Link("Open System Notification Settings", destination: settingsUrl)
                } header: {
                    Text("System Settings")
                } footer: {
                    Text("Enable or disable the app's permission to send notifications")
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: reactioNotificationDeliveryType) { _, newState in
            Task {
                await notificationEnvironmentModel
                    .updatePushNotificationSettingsForDevice(sendReactionNotifications: newState ==
                        .pushNotification)
                await profileEnvironmentModel
                    .updateNotificationSettings(sendReactionNotifications: newState != .disabled)
            }
        }
        .onChange(of: checkInNotificationDeliveryType) { _, newState in
            Task {
                await notificationEnvironmentModel
                    .updatePushNotificationSettingsForDevice(sendTaggedCheckInNotifications: newState ==
                        .pushNotification)
                await profileEnvironmentModel
                    .updateNotificationSettings(sendTaggedCheckInNotifications: newState != .disabled)
            }
        }
        .onChange(of: friendRequestNotificationDeliveryType) { _, newState in
            Task {
                await notificationEnvironmentModel
                    .updatePushNotificationSettingsForDevice(sendFriendRequestNotifications: newState ==
                        .pushNotification)
                await profileEnvironmentModel
                    .updateNotificationSettings(sendFriendRequestNotifications: newState != .disabled)
            }
        }
        .onChange(of: checkInCommentNotificationsDeliveryType) { _, newState in
            Task {
                await notificationEnvironmentModel
                    .updatePushNotificationSettingsForDevice(sendCheckInCommentNotifications: newState ==
                        .pushNotification)
                await profileEnvironmentModel
                    .updateNotificationSettings(sendCheckInCommentNotifications: newState != .disabled)
            }
        }
        .task {
            if !initialValuesLoaded {
                reactioNotificationDeliveryType = profileEnvironmentModel
                    .reactionNotifications ? notificationEnvironmentModel
                    .pushNotificationSettings?
                    .sendReactionNotifications ?? false ? .pushNotification : .inApp : .disabled
                checkInNotificationDeliveryType = profileEnvironmentModel
                    .checkInTagNotifications ? notificationEnvironmentModel
                    .pushNotificationSettings?
                    .sendTaggedCheckInNotifications ?? false ? .pushNotification : .inApp :
                    .disabled
                friendRequestNotificationDeliveryType = profileEnvironmentModel
                    .friendRequestNotifications ? notificationEnvironmentModel
                    .pushNotificationSettings?
                    .sendFriendRequestNotifications ?? false ? .pushNotification : .inApp :
                    .disabled
                checkInCommentNotificationsDeliveryType = profileEnvironmentModel
                    .sendCommentNotifications ? notificationEnvironmentModel
                    .pushNotificationSettings?
                    .sendCheckInCommentNotifications ?? false ? .pushNotification : .inApp :
                    .disabled
            }
            initialValuesLoaded = true
        }
    }
}

struct NotificationDeliveryTypePicker: View {
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
