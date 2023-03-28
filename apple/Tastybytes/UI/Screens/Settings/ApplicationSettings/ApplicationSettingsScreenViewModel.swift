import SwiftUI

extension ApplicationSettingsScreen {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ApplicationSettingsScreen")
    let client: Client
    @Published var isSystemColor = false
    @Published var isDarkMode = false
    @Published var reactionNotifications = true
    @Published var friendRequestNotifications = true
    @Published var checkInTagNotifications = true

    var initialColorScheme: ColorScheme?

    init(_ client: Client) {
      self.client = client
    }

    func setInitialValues(systemColorScheme: ColorScheme, profile _: Profile.Extended?) {
      Task {
        switch await client.profile.getCurrentUser() {
        case let .success(profile):
          switch profile.settings.colorScheme {
          case .light:
            self.isDarkMode = false
            self.isSystemColor = false
          case .dark:
            self.isDarkMode = true
            self.isSystemColor = false
          case .system:
            self.isDarkMode = initialColorScheme == ColorScheme.dark
            self.isSystemColor = true
          }

          self.reactionNotifications = profile.settings.sendReactionNotifications
          self.friendRequestNotifications = profile.settings.sendFriendRequestNotifications
          self.checkInTagNotifications = profile.settings.sendTaggedCheckInNotifications

          initialColorScheme = systemColorScheme
        case let .failure(error):
          logger.error("fetching current user failed: \(error.localizedDescription)")
        }
      }
    }

    func updateColorScheme(_ onChange: @escaping () -> Void) {
      if isSystemColor {
        isDarkMode = initialColorScheme == ColorScheme.dark
      }
      let update = ProfileSettings.UpdateRequest(
        isDarkMode: isDarkMode, isSystemColor: isSystemColor
      )

      Task {
        switch await client.profile.updateSettings(
          update: update
        ) {
        case .success:
          onChange()
        case let .failure(error):
          logger.error("updating color scheme failed: \(error.localizedDescription)")
        }
      }
    }

    func updateNotificationSettings() {
      let update = ProfileSettings.UpdateRequest(
        sendReactionNotifications: reactionNotifications,
        sendTaggedCheckInNotifications: checkInTagNotifications,
        sendFriendRequestNotifications: friendRequestNotifications
      )

      Task {
        _ = await client.profile.updateSettings(
          update: update
        )
      }
    }
  }
}
