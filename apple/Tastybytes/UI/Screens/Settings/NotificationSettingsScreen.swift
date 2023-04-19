import SwiftUI

struct NotificationSettingsScreen: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.colorScheme) private var systemColorScheme

  var body: some View {
    Form {
      Section {
        Toggle("Reactions", isOn: .init(get: {
          profileManager.reactionNotifications
        }, set: { newValue in
          profileManager.reactionNotifications = newValue
          Task { await profileManager.updateNotificationSettings() }
        }))
        Toggle("Friend Requests", isOn: .init(get: {
          profileManager.friendRequestNotifications
        }, set: { newValue in
          profileManager.friendRequestNotifications = newValue
          Task { await profileManager.updateNotificationSettings() }
        }))
        Toggle("Check-in Tags", isOn: .init(get: {
          profileManager.checkInTagNotifications
        }, set: { newValue in
          profileManager.checkInTagNotifications = newValue
          Task { await profileManager.updateNotificationSettings() }
        }))
      }
      Section {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
          Link("Open Notification Settings", destination: settingsUrl)
        }
      }
    }
    .navigationTitle("Notifications")
    .navigationBarTitleDisplayMode(.inline)
  }
}
