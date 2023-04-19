import PhotosUI
import SwiftUI

@MainActor
final class ProfileManager: ObservableObject {
  private let logger = getLogger(category: "ProfileManager")
  @Published private(set) var isLoggedIn = false
  @Published private(set) var colorScheme: ColorScheme?

  // Profile Settings
  @Published var showFullName = false
  @Published var showProfileUpdateButton = false
  @Published var isPrivateProfile = true

  // Account Settings
  @Published var email = ""
  @Published var csvExport: CSVFile?
  @Published var showingExporter = false

  // Application Settings
  @Published var initialValuesLoaded = true
  @Published var isSystemColor = false
  @Published var isDarkMode = false
  @Published var reactionNotifications = true
  @Published var friendRequestNotifications = true
  @Published var checkInTagNotifications = true

  // AppIcon
  @Published var appIcon: AppIcon = .ramune

  let repository: Repository

  init(repository: Repository) {
    self.repository = repository
  }

  var initialColorScheme: ColorScheme?

  func updateColorScheme() async {
    if isSystemColor {
      isDarkMode = initialColorScheme == ColorScheme.dark
    }
    let update = ProfileSettings.UpdateRequest(
      isDarkMode: isDarkMode, isSystemColor: isSystemColor
    )

    switch await repository.profile.updateSettings(
      update: update
    ) {
    case .success:
      setPreferredColorScheme(profileColorScheme: isSystemColor ? .system : isDarkMode ? .dark : .light)
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

    _ = await repository.profile.updateSettings(
      update: update
    )
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
    switch await repository.profile.getCurrentUser() {
    case let .success(currentUserProfile):
      profile = currentUserProfile
      setPreferredColorScheme(profileColorScheme: currentUserProfile.settings.colorScheme)
      showFullName = currentUserProfile.nameDisplay == Profile.NameDisplay.fullName
      isPrivateProfile = currentUserProfile.isPrivate

      switch currentUserProfile.settings.colorScheme {
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

      reactionNotifications = currentUserProfile.settings.sendReactionNotifications
      friendRequestNotifications = currentUserProfile.settings.sendFriendRequestNotifications
      checkInTagNotifications = currentUserProfile.settings.sendTaggedCheckInNotifications
      initialValuesLoaded = false
      isLoggedIn = true
    case let .failure(error):
      logger.error("error while loading current user profile: \(error.localizedDescription)")
      isLoggedIn = false
      _ = await repository.auth.logOut()
    }

    switch await repository.auth.getUser() {
    case let .success(user):
      email = user.email.orEmpty
    case let .failure(error):
      logger.error("failed to get current user data: \(error.localizedDescription)")
    }
  }

  func checkIfUsernameIsAvailable(username: String) async -> Bool {
    switch await repository.profile.checkIfUsernameIsAvailable(username: username) {
    case let .success(usernameExists):
      return !usernameExists
    case let .failure(error):
      logger.error("failed to check if username is available: \(error.localizedDescription)")
      return true
    }
  }

  func hasPermission(_ permission: PermissionName) -> Bool {
    guard let roles = profile?.roles else { return false }
    let permissions = roles.flatMap(\.permissions)
    return permissions.contains(where: { $0.name == permission.rawValue })
  }

  func setPreferredColorScheme(profileColorScheme: ProfileSettings.ColorScheme) {
    switch profileColorScheme {
    case ProfileSettings.ColorScheme.dark:
      colorScheme = ColorScheme.dark
    case ProfileSettings.ColorScheme.light:
      colorScheme = ColorScheme.light
    case ProfileSettings.ColorScheme.system:
      colorScheme = nil
    }
  }

  func logOut() async {
    _ = await repository.auth.logOut()
  }

  func updatePassword(newPassword: String) async {
    _ = await repository.auth.updatePassword(newPassword: newPassword)
  }

  func sendEmailVerificationLink() async {
    _ = await repository.auth.sendEmailVerification(email: email)
  }

  func deleteCurrentAccount(onError: @escaping (_ error: String) -> Void) async {
    switch await repository.profile.deleteCurrentAccount() {
    case .success:
      _ = await repository.auth.logOut()
    case let .failure(error):
      logger.error("failed to delete current account: \(error.localizedDescription)")
      onError(error.localizedDescription)
    }
  }

  func uploadAvatar(newAvatar: PhotosPickerItem, onError: @escaping (_ error: Error) -> Void) async {
    guard let data = await newAvatar.getJPEG() else { return }
    guard let profile else { return }
    switch await repository.profile.uploadAvatar(userId: profile.id, data: data) {
    case .success:
      // TODO: update only avatar url
      await refresh()
    case let .failure(error):
      onError(error)
      logger.error("uplodaing avatar failed: \(error.localizedDescription)")
    }
  }

  func updateProfile(
    update: Profile.UpdateRequest,
    onSuccess: @escaping () async -> Void,
    onError: @escaping (_ error: Error) -> Void
  ) async {
    switch await repository.profile.update(
      update: update
    ) {
    case .success:
      await onSuccess()
    case let .failure(error):
      onError(error)
      logger.error("failed to update profile: \(error.localizedDescription)")
    }
  }

  func onboardingUpdate(onError: @escaping (_ error: Error) -> Void) async {
    let update = Profile.UpdateRequest(
      isPrivate: isPrivateProfile,
      showFullName: showFullName,
      isOnboarded: true
    )

    switch await repository.profile.update(
      update: update
    ) {
    case .success:
      logger.info("onboarded")
    case let .failure(error):
      onError(error)
      logger.error("failed to update profile: \(error.localizedDescription)")
    }
  }

  func updatePrivacySettings(onError: @escaping (_ error: Error) -> Void) async {
    let update = Profile.UpdateRequest(isPrivate: isPrivateProfile)
    switch await repository.profile.update(
      update: update
    ) {
    case .success:
      logger.log("updated privacy settings")
    case let .failure(error):
      onError(error)
      logger.error("failed to update settings: \(error.localizedDescription)")
    }
  }

  func updateDisplaySettings(onError: @escaping (_ error: String) -> Void) async {
    let update = Profile.UpdateRequest(
      showFullName: showFullName
    )
    switch await repository.profile.update(
      update: update
    ) {
    case .success:
      logger.log("updated display settings")
    case let .failure(error):
      onError(error.localizedDescription)
      logger.error("failed to update profile: \(error.localizedDescription)")
    }
  }

  func getCSVExportName() -> String {
    "\(Config.appName.lowercased())_export_\(Date().customFormat(.fileNameSuffix)).csv"
  }

  func exportData(onError: @escaping (_ error: String) -> Void) async {
    switch await repository.profile.currentUserExport() {
    case let .success(csvText):
      csvExport = CSVFile(initialText: csvText)
      showingExporter = true
    case let .failure(error):
      onError(error.localizedDescription)
      logger.error("failed to export check-in csv: \(error.localizedDescription)")
    }
  }
}
