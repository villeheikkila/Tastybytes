import SwiftUI

@MainActor
class ProfileManager: ObservableObject {
  private let logger = getLogger(category: "ProfileManager")
  let client: Client
  @Published private(set) var isLoggedIn = false
  @Published private(set) var colorScheme: ColorScheme?

  init(_ client: Client) {
    self.client = client
  }

  private var profile: Profile.Extended?

  func get() -> Profile.Extended {
    guard let profile else { fatalError("ProfileManager.get() can only be used on authenticated routes.") }
    return profile
  }

  func getProfile() -> Profile {
    guard let profile = profile?.getProfile()
    else { fatalError("ProfileManager.getProfile() can only be used on authenticated routes.") }
    return profile
  }

  func getId() -> UUID {
    guard let id = profile?.id
    else { fatalError("ProfileManager.getProfile() can only be used on authenticated routes.") }
    return id
  }

  func refresh() async {
    switch await client.profile.getCurrentUser() {
    case let .success(currentUserProfile):
      profile = currentUserProfile
      setPreferredColorScheme(settings: currentUserProfile.settings)
      isLoggedIn = true
    case let .failure(error):
      logger.error("error while loading current user profile: \(error.localizedDescription)")
      isLoggedIn = false
      _ = await client.auth.logOut()
    }
  }

  func hasPermission(_ permission: PermissionName) -> Bool {
    guard let roles = profile?.roles else { return false }
    let permissions = roles.flatMap(\.permissions)
    return permissions.contains(where: { $0.name == permission.rawValue })
  }

  func setPreferredColorScheme(settings: ProfileSettings) {
    switch settings.colorScheme {
    case ProfileSettings.ColorScheme.dark:
      colorScheme = ColorScheme.dark
    case ProfileSettings.ColorScheme.light:
      colorScheme = ColorScheme.light
    case ProfileSettings.ColorScheme.system:
      colorScheme = nil
    }
  }

  func logOut() async {
    await client.auth.logOut()
  }
}
