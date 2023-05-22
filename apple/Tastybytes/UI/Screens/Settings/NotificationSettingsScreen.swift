import SwiftUI

enum NotificationDeliveryType: String, CaseIterable {
  case disabled = "Disabled"
  case inApp = "In-App"
  case pushNotification = "Push Notification"

  var label: String {
    rawValue
  }
}

struct NotificationSettingsScreen: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var notificationManager: NotificationManager
  @State private var initialValuesLoaded = false
  @State private var reactioNotificationDeliveryType: NotificationDeliveryType = .disabled
  @State private var checkInNotificationDeliveryType: NotificationDeliveryType = .disabled
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
          notificationDeliveryType: $checkInNotificationDeliveryType,
          title: "Check-ins",
          subtitle: "Show notification when someone tags you in their check-in"
        )
        NotificationDeliveryTypePicker(
          notificationDeliveryType: $friendRequestNotificationDeliveryType,
          title: "Friend Requests",
          subtitle: "Show notification when someone sends you a friend requests"
        )
      }
      Section {
        if let settingsUrl = URL(string: UIApplication.openNotificationSettingsURLString) {
          Link("Open System Notification Settings", destination: settingsUrl)
        }
      }
    }
    .navigationTitle("Notifications")
    .navigationBarTitleDisplayMode(.inline)
    .onChange(of: reactioNotificationDeliveryType, perform: { newValue in
      Task {
        await notificationManager
          .updatePushNotificationSettingsForDevice(sendReactionNotifications: newValue ==
            .pushNotification)
        await profileManager
          .updateNotificationSettings(sendReactionNotifications: newValue != .disabled)
      }
    })
    .onChange(of: checkInNotificationDeliveryType, perform: { newValue in
      Task {
        await notificationManager
          .updatePushNotificationSettingsForDevice(sendTaggedCheckInNotifications: newValue ==
            .pushNotification)
        await profileManager
          .updateNotificationSettings(sendTaggedCheckInNotifications: newValue != .disabled)
      }
    })
    .onChange(of: friendRequestNotificationDeliveryType, perform: { newValue in
      Task {
        await notificationManager
          .updatePushNotificationSettingsForDevice(sendFriendRequestNotifications: newValue ==
            .pushNotification)
        await profileManager
          .updateNotificationSettings(sendFriendRequestNotifications: newValue != .disabled)
      }
    })
    .task {
      if !initialValuesLoaded {
        reactioNotificationDeliveryType = profileManager.reactionNotifications ? notificationManager
          .pushNotificationSettings?.sendReactionNotifications ?? false ? .pushNotification : .inApp : .disabled
        checkInNotificationDeliveryType = profileManager.checkInTagNotifications ? notificationManager
          .pushNotificationSettings?.sendTaggedCheckInNotifications ?? false ? .pushNotification : .inApp : .disabled
        friendRequestNotificationDeliveryType = profileManager.friendRequestNotifications ? notificationManager
          .pushNotificationSettings?.sendFriendRequestNotifications ?? false ? .pushNotification : .inApp : .disabled
      }
      initialValuesLoaded = true
    }
  }
}

struct NotificationDeliveryTypePicker: View {
  @Binding var notificationDeliveryType: NotificationDeliveryType

  let title: String
  let subtitle: String?

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
