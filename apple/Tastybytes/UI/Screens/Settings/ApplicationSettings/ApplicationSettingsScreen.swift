import SwiftUI

struct ApplicationSettingsScreen: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.colorScheme) private var systemColorScheme

  var body: some View {
    Form {
      colorSchemeSection
      notificationSection
    }
    .navigationTitle("Application")
    .navigationBarTitleDisplayMode(.inline)
  }

  private var colorSchemeSection: some View {
    Section {
      Toggle("Use System Color Scheme", isOn: .init(get: {
        profileManager.isSystemColor
      }, set: { newValue in
        profileManager.isSystemColor = newValue
        Task { await profileManager.updateColorScheme() }
      }))
      Toggle("Use Dark Mode", isOn: .init(get: {
        systemColorScheme == .dark
      }, set: { newValue in
        profileManager.isDarkMode = newValue
        Task { await profileManager.updateColorScheme() }
      }))
      .disabled(profileManager.isSystemColor)
    } header: {
      Text("Color Scheme")
    }
  }

  private var notificationSection: some View {
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
    } header: {
      Text("Notifications")
    }
  }
}
