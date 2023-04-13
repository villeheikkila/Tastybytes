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

    func setInitialValues(systemColorScheme: ColorScheme, profile _: Profile.Extended?) async {
      switch await client.profile.getCurrentUser() {
      case let .success(profile):
        switch profile.settings.colorScheme {
        case .light:
          isDarkMode = false
          isSystemColor = false
        case .dark:
          isDarkMode = true
          isSystemColor = false
        case .system:
          isDarkMode = initialColorScheme == ColorScheme.dark
          isSystemColor = true
        }

        reactionNotifications = profile.settings.sendReactionNotifications
        friendRequestNotifications = profile.settings.sendFriendRequestNotifications
        checkInTagNotifications = profile.settings.sendTaggedCheckInNotifications

        initialColorScheme = systemColorScheme
      case let .failure(error):
        logger.error("fetching current user failed: \(error.localizedDescription)")
      }
    }

    func updateColorScheme(_ onChange: @escaping () async -> Void) async {
      if isSystemColor {
        isDarkMode = initialColorScheme == ColorScheme.dark
      }
      let update = ProfileSettings.UpdateRequest(
        isDarkMode: isDarkMode, isSystemColor: isSystemColor
      )

      switch await client.profile.updateSettings(
        update: update
      ) {
      case .success:
        await onChange()
      case let .failure(error):
        logger.error("updating color scheme failed: \(error.localizedDescription)")
      }
    }

    func updateNotificationSettings() async {
      let update = ProfileSettings.UpdateRequest(
        sendReactionNotifications: reactionNotifications,
        sendTaggedCheckInNotifications: checkInTagNotifications,
        sendFriendRequestNotifications: friendRequestNotifications
      )

      _ = await client.profile.updateSettings(
        update: update
      )
    }
  }
}
