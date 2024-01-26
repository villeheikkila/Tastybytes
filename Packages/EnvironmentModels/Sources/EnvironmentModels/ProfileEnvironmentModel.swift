import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

public enum ProfileState: Sendable {
    case uninitialized, initialized, error
}

@MainActor
@Observable
public final class ProfileEnvironmentModel: ObservableObject {
    private let logger = Logger(category: "ProfileEnvironmentModel")
    // Auth state
    public var profileState: ProfileState = .uninitialized
    public var authState: AuthState?
    private var initialValuesLoaded = false
    public var alertError: AlertError?

    // Profile Settings
    public var showFullName = false
    public var isPrivateProfile = true

    // Account Settings
    public var email = ""

    // Application Settings
    public var reactionNotifications = true
    public var friendRequestNotifications = true
    public var checkInTagNotifications = true
    public var sendCommentNotifications = true

    // AppIcon
    public var appIcon: AppIcon = .ramune

    private let repository: Repository
    private var extendedProfile: Profile.Extended?

    public init(repository: Repository) {
        self.repository = repository
    }

    // Session
    public func listenToAuthState() async {
        for await state in await repository.auth.authStateListener() {
            let previousState = authState
            authState = state
            logger.info("Auth state changed from \(String(describing: previousState)) to \(String(describing: state))")
            if state == .authenticated {
                await initialize()
            }
            if Task.isCancelled {
                logger.info("Auth state listener cancelled")
                return
            }
        }
    }

    public func loadSessionFromURL(url: URL) async {
        let result = await repository.auth.signInFromUrl(url: url)
        if case let .failure(error) = result {
            logger.error("Failed to load session from url: \(url). Error: \(error) (\(#file):\(#line))")
        }
    }

    // Getters that are only available after authentication, calling these before authentication causes an app crash
    public var profile: Profile {
        if let extendedProfile {
            extendedProfile.profile
        } else {
            fatalError("profile can only be used on authenticated routes.")
        }
    }

    public var id: UUID {
        if let extendedProfile {
            extendedProfile.id
        } else {
            fatalError("id can only be used on authenticated routes.")
        }
    }

    public var username: String {
        if let extendedProfile {
            extendedProfile.username ?? ""
        } else {
            fatalError("username can only be used on authenticated routes.")
        }
    }

    public var firstName: String? {
        if let extendedProfile {
            extendedProfile.firstName
        } else {
            fatalError("username can only be used on authenticated routes.")
        }
    }

    public var lastName: String? {
        if let extendedProfile {
            extendedProfile.lastName
        } else {
            fatalError("username can only be used on authenticated routes.")
        }
    }

    public var isOnboarded: Bool {
        if let extendedProfile {
            extendedProfile.isOnboarded
        } else {
            fatalError("isOnboarded can only be used on authenticated routes.")
        }
    }

    // Access Control
    public func hasPermission(_ permission: PermissionName) -> Bool {
        guard let roles = extendedProfile?.roles else { return false }
        let permissions = roles.flatMap(\.permissions)
        return permissions.contains(where: { $0.name == permission.rawValue })
    }

    public func hasRole(_ role: RoleName) -> Bool {
        guard let roles = extendedProfile?.roles else { return false }
        return roles.contains(where: { $0.name == role.rawValue })
    }

    public func hasChanged(username: String, firstName: String, lastName: String) -> Bool {
        guard let extendedProfile else { return false }
        return !(username == extendedProfile.username &&
            firstName == extendedProfile.firstName ?? "" &&
            lastName == extendedProfile.lastName ?? "")
    }

    public func initialize() async {
        logger.notice("Initializing user data")
        let startTime = DispatchTime.now()
        async let profilePromise = await repository.profile.getCurrentUser()
        async let userPromise = await repository.auth.getUser()

        let (profileResult, userResult) = await (profilePromise, userPromise)

        switch profileResult {
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
            profileState = .initialized
            logger.info("User data initialized in \(startTime.elapsedTime())ms")
        case let .failure(error):
            profileState = .error
            logger.error("Error while loading current user profile. Error: \(error) (\(#file):\(#line))")
            await logOut()
        }

        switch userResult {
        case let .success(user):
            email = user.email.orEmpty
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to get current user data. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func checkIfUsernameIsAvailable(username: String) async -> Bool {
        switch await repository.profile.checkIfUsernameIsAvailable(username: username) {
        case let .success(isAvailable):
            return isAvailable
        case let .failure(error):
            logger.error("Failed to check if username is available. Error: \(error) (\(#file):\(#line))")
            return true
        }
    }

    public func updateNotificationSettings(sendReactionNotifications: Bool? = nil,
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
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to update notification settings. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func logOut() async {
        switch await repository.auth.logOut() {
        case .success:
            clearTemporaryData()
            UserDefaults().reset()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to log out. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func deleteCurrentAccount(onAccountDeletion: @MainActor @Sendable @escaping () -> Void) async {
        switch await repository.profile.deleteCurrentAccount() {
        case .success:
            onAccountDeletion()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete current account. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func uploadAvatar(data: Data) async {
        guard let extendedProfile else { return }
        switch await repository.profile.uploadAvatar(userId: extendedProfile.id, data: data) {
        case let .success(imageEntity):
            self.extendedProfile = extendedProfile.copyWith(avatars: [imageEntity])
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("uplodaing avatar failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func updateProfile(update: Profile.UpdateRequest) async {
        switch await repository.profile.update(
            update: update
        ) {
        case .success:
            extendedProfile = extendedProfile?.copyWith(
                username: update.username,
                firstName: update.firstName,
                lastName: update.lastName
            )
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to update profile. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func onboardingUpdate() async {
        let update = Profile.UpdateRequest(
            isOnboarded: true
        )

        switch await repository.profile.update(
            update: update
        ) {
        case .success:
            extendedProfile = extendedProfile?.copyWith(isOnboarded: true)
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to update profile. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func updatePrivacySettings() async {
        let update = Profile.UpdateRequest(isPrivate: isPrivateProfile)
        switch await repository.profile.update(
            update: update
        ) {
        case .success:
            logger.log("updated privacy settings")
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to update settings. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func updateDisplaySettings() async {
        let update = Profile.UpdateRequest(
            showFullName: showFullName
        )
        switch await repository.profile.update(
            update: update
        ) {
        case .success:
            logger.log("updated display settings")
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to update profile. Error: \(error) (\(#file):\(#line))")
        }
    }
}
