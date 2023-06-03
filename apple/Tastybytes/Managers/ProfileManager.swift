import PhotosUI
import SwiftUI

@MainActor
final class ProfileManager: ObservableObject {
  private let logger = getLogger(category: "ProfileManager")
  @Published private(set) var isLoggedIn = false

  // Profile Settings
  @Published var showFullName = false
  @Published var showProfileUpdateButton = false
  @Published var isPrivateProfile = true

  // Account Settings
  @Published var email = ""
  @Published var csvExport: CSVFile?
  @Published var showingExporter = false

  // Application Settings
  @Published var initialValuesLoaded = false
  @Published var reactionNotifications = true
  @Published var friendRequestNotifications = true
  @Published var checkInTagNotifications = true
  @Published var sendCommentNotifications = true

  // AppIcon
  @Published var appIcon: AppIcon = .ramune

  private let repository: Repository
  private let feedbackManager: FeedbackManager

  init(repository: Repository, feedbackManager: FeedbackManager) {
    self.repository = repository
    self.feedbackManager = feedbackManager
  }

  private var initialColorScheme: ColorScheme?
  private var extendedProfile: Profile.Extended?

  // Getters
  var profile: Profile {
    if let extendedProfile {
      return extendedProfile.profile
    } else {
      fatalError("profile can only be used on authenticated routes.")
    }
  }

  var id: UUID {
    if let extendedProfile {
      return extendedProfile.id
    } else {
      fatalError("id can only be used on authenticated routes.")
    }
  }

  var username: String {
    if let extendedProfile {
      return extendedProfile.username
    } else {
      fatalError("username can only be used on authenticated routes.")
    }
  }

  var firstName: String? {
    if let extendedProfile {
      return extendedProfile.firstName
    } else {
      fatalError("username can only be used on authenticated routes.")
    }
  }

  var lastName: String? {
    if let extendedProfile {
      return extendedProfile.lastName
    } else {
      fatalError("username can only be used on authenticated routes.")
    }
  }

  var isOnboarded: Bool {
    if let extendedProfile {
      return extendedProfile.isOnboarded
    } else {
      fatalError("isOnboarded can only be used on authenticated routes.")
    }
  }

  // Access Control
  func hasPermission(_ permission: PermissionName) -> Bool {
    guard let roles = extendedProfile?.roles else { return false }
    let permissions = roles.flatMap(\.permissions)
    return permissions.contains(where: { $0.name == permission.rawValue })
  }

  func hasRole(_ role: RoleName) -> Bool {
    guard let roles = extendedProfile?.roles else { return false }
    return roles.contains(where: { $0.name == role.rawValue })
  }

  func hasChanged(username: String, firstName: String, lastName: String) -> Bool {
    guard let extendedProfile else { return false }
    return !(username == extendedProfile.username &&
      firstName == extendedProfile.firstName ?? "" &&
      lastName == extendedProfile.lastName ?? "")
  }

  func initialize() async {
    switch await repository.profile.getCurrentUser() {
    case let .success(currentUserProfile):
      extendedProfile = currentUserProfile
      showFullName = currentUserProfile.nameDisplay == Profile.NameDisplay.fullName
      isPrivateProfile = currentUserProfile.isPrivate
      reactionNotifications = currentUserProfile.settings.sendReactionNotifications
      friendRequestNotifications = currentUserProfile.settings.sendFriendRequestNotifications
      checkInTagNotifications = currentUserProfile.settings.sendTaggedCheckInNotifications
      sendCommentNotifications = currentUserProfile.settings.sendCommentNotifications
      appIcon = getCurrentAppIcon()
      initialValuesLoaded = true
      isLoggedIn = true
    case let .failure(error):
      logger.error("error while loading current user profile: \(error.localizedDescription)")
      isLoggedIn = false
      await logOut()
    }

    switch await repository.auth.getUser() {
    case let .success(user):
      email = user.email.orEmpty
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to get current user data: \(error.localizedDescription)")
    }
  }

  func checkIfUsernameIsAvailable(username: String) async -> Bool {
    switch await repository.profile.checkIfUsernameIsAvailable(username: username) {
    case let .success(isAvailable):
      return isAvailable
    case let .failure(error):
      logger.error("failed to check if username is available: \(error.localizedDescription)")
      return true
    }
  }

  func updateNotificationSettings(sendReactionNotifications: Bool? = nil,
                                  sendTaggedCheckInNotifications: Bool? = nil,
                                  sendFriendRequestNotifications: Bool? = nil,
                                  sendCheckInCommentNotifications: Bool? = nil) async
  {
    let update = ProfileSettings.UpdateRequest(
      sendReactionNotifications: sendReactionNotifications,
      sendTaggedCheckInNotifications: sendTaggedCheckInNotifications,
      sendFriendRequestNotifications: sendFriendRequestNotifications,
      sendCommentNotifications: sendCheckInCommentNotifications
    )

    if case let .failure(error) = await repository.profile.updateSettings(
      update: update
    ) {
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to update notification settings: \(error.localizedDescription)")
    }
  }

  func logOut() async {
    if case let .failure(error) = await repository.auth.logOut() {
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to log out: \(error.localizedDescription)")
    }
  }

  func updatePassword(newPassword: String) async {
    if case let .failure(error) = await repository.auth.updatePassword(newPassword: newPassword) {
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to update password: \(error.localizedDescription)")
    }
  }

  func sendEmailVerificationLink() async {
    if case let .failure(error) = await repository.auth.sendEmailVerification(email: email) {
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to send email verification link: \(error.localizedDescription)")
    }
  }

  func deleteCurrentAccount(onAccountDeletion: @escaping () -> Void) async {
    switch await repository.profile.deleteCurrentAccount() {
    case .success:
      feedbackManager.trigger(.notification(.success))
      onAccountDeletion()
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to delete current account: \(error.localizedDescription)")
    }
  }

  func uploadAvatar(newAvatar: PhotosPickerItem) async {
    guard let data = await newAvatar.getJPEG() else { return }
    guard let extendedProfile else { return }
    switch await repository.profile.uploadAvatar(userId: extendedProfile.id, data: data) {
    case let .success(avatarFile):
      self.extendedProfile = extendedProfile.copyWith(avatarFile: avatarFile)
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("uplodaing avatar failed: \(error.localizedDescription)")
    }
  }

  func updateProfile(
    update: Profile.UpdateRequest
  ) async {
    switch await repository.profile.update(
      update: update
    ) {
    case .success:
      extendedProfile = extendedProfile?.copyWith(
        username: update.username,
        firstName: update.firstName,
        lastName: update.lastName
      )
      feedbackManager.toggle(.success("Profile updated!"))
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to update profile: \(error.localizedDescription)")
    }
  }

  func onboardingUpdate() async {
    let update = Profile.UpdateRequest(
      isOnboarded: true
    )

    switch await repository.profile.update(
      update: update
    ) {
    case .success:
      logger.info("onboarded")
      extendedProfile = extendedProfile?.copyWith(isOnboarded: true)
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to update profile: \(error.localizedDescription)")
    }
  }

  func updatePrivacySettings() async {
    let update = Profile.UpdateRequest(isPrivate: isPrivateProfile)
    switch await repository.profile.update(
      update: update
    ) {
    case .success:
      logger.log("updated privacy settings")
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to update settings: \(error.localizedDescription)")
    }
  }

  func updateDisplaySettings() async {
    let update = Profile.UpdateRequest(
      showFullName: showFullName
    )
    switch await repository.profile.update(
      update: update
    ) {
    case .success:
      logger.log("updated display settings")
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to update profile: \(error.localizedDescription)")
    }
  }

  func getCSVExportName() -> String {
    "\(Config.appName.lowercased())_export_\(Date().customFormat(.fileNameSuffix)).csv"
  }

  func exportData() async {
    switch await repository.profile.currentUserExport() {
    case let .success(csvText):
      csvExport = CSVFile(initialText: csvText)
      showingExporter = true
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to export check-in csv: \(error.localizedDescription)")
    }
  }
}
