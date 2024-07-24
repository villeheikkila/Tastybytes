import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

public enum ProfileState: Sendable {
    case loading, populated(Profile.Extended), error([Error])

    public static func == (lhs: ProfileState, rhs: ProfileState) -> Bool {
        switch (lhs, rhs) {
        case let (.populated(lhsProfile), .populated(rhsProfile)):
            lhsProfile == rhsProfile
        case (.loading, .loading):
            true
        case let (.error(lhsErrors), .error(rhsErrors)):
            lhsErrors.count == rhsErrors.count && lhsErrors.elementsEqual(rhsErrors, by: { $0.localizedDescription == $1.localizedDescription })
        default:
            false
        }
    }
}

@MainActor
@Observable
public final class ProfileEnvironmentModel {
    private let logger = Logger(category: "ProfileEnvironmentModel")
    // Auth state
    public var profileState: ProfileState = .loading
    public var authState: AuthState?
    public var alertError: AlertEvent?

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

    public var extendedProfile: Profile.Extended? {
        get {
            access(keyPath: \.extendedProfile)
            return UserDefaults.read(forKey: .profileData)
        }

        set {
            withMutation(keyPath: \.extendedProfile) {
                UserDefaults.set(value: newValue, forKey: .profileData)
            }
        }
    }

    public init(repository: Repository) {
        self.repository = repository
    }

    // Session
    public func listenToAuthState() async {
        do {
            for await state in try await repository.auth.authStateListener() {
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
        } catch {
            logger.error("Error while listening to auth state. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func loadSessionFromURL(url: URL) async {
        do {
            try await repository.auth.signInFromUrl(url: url)
        } catch {
            logger.error("Failed to load session from url: \(url). Error: \(error) (\(#file):\(#line))")
        }
    }

    // App icon
    public func setAppIcon(_ appIcon: AppIcon) {
        #if !os(watchOS)
            UIApplication.shared.setAlternateIconName(appIcon == AppIcon.ramune ? nil : appIcon.rawValue)
        #endif
        self.appIcon = appIcon
    }

    // Getters that are only available after authentication, calling these before authentication causes an app crash
    public var profile: Profile.Saved {
        if let extendedProfile {
            extendedProfile.profile
        } else {
            fatalError("profile can only be used on authenticated routes.")
        }
    }

    public var id: Profile.Id {
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
    public func hasPermission(_ permission: Permission.Name) -> Bool {
        guard let roles = extendedProfile?.roles else { return false }
        let permissions = roles.flatMap(\.permissions)
        return permissions.contains(where: { $0.name == permission.rawValue })
    }

    public func hasRole(_ role: Role.Name) -> Bool {
        extendedProfile?.hasRole(role) ?? false
    }

    public func hasChanged(username: String, firstName: String, lastName: String) -> Bool {
        guard let extendedProfile else { return false }
        return !(username == extendedProfile.username &&
            firstName == extendedProfile.firstName ?? "" &&
            lastName == extendedProfile.lastName ?? "")
    }

    public func initialize() async {
        logger.notice("Initializing user data")
        let isPreviouslyLoaded = extendedProfile != nil
        if let extendedProfile {
            showFullName = extendedProfile.nameDisplay == Profile.NameDisplay.fullName
            isPrivateProfile = extendedProfile.isPrivate
            reactionNotifications = extendedProfile.settings.sendReactionNotifications
            friendRequestNotifications = extendedProfile.settings.sendFriendRequestNotifications
            checkInTagNotifications = extendedProfile.settings.sendTaggedCheckInNotifications
            sendCommentNotifications = extendedProfile.settings.sendCommentNotifications
            appIcon = .currentAppIcon
            profileState = .populated(extendedProfile)
            logger.info("Profile data optimistically initialized based on previously stored data, refreshing...")
        }

        let startTime = DispatchTime.now()
        async let profilePromise = await repository.profile.getCurrentUser()
        async let userPromise = await repository.auth.getUser()

        var errors = [Error]()
        do {
            let (currentUserProfile, userResult) = try await (profilePromise, userPromise)
            extendedProfile = currentUserProfile
            showFullName = currentUserProfile.nameDisplay == Profile.NameDisplay.fullName
            isPrivateProfile = currentUserProfile.isPrivate
            reactionNotifications = currentUserProfile.settings.sendReactionNotifications
            friendRequestNotifications = currentUserProfile.settings.sendFriendRequestNotifications
            checkInTagNotifications = currentUserProfile.settings.sendTaggedCheckInNotifications
            sendCommentNotifications = currentUserProfile.settings.sendCommentNotifications
            appIcon = .currentAppIcon
            email = userResult.email.orEmpty
            logger.info("User data initialized in \(startTime.elapsedTime())ms")
        } catch {
            errors.append(error)
            logger.error("Error while loading current user profile. Error: \(error) (\(#file):\(#line))")
        }
        guard !isPreviouslyLoaded else { return }
        withAnimation {
            profileState = if errors.isEmpty, let extendedProfile {
                .populated(extendedProfile)
            } else {
                .error(errors)
            }
        }
    }

    public func checkIfUsernameIsAvailable(username: String) async -> Bool {
        do {
            return try await repository.profile.checkIfUsernameIsAvailable(username: username)
        } catch {
            logger.error("Failed to check if username is available. Error: \(error) (\(#file):\(#line))")
            return false
        }
    }

    public func updateNotificationSettings(sendReactionNotifications: Bool? = nil,
                                           sendTaggedCheckInNotifications: Bool? = nil,
                                           sendFriendRequestNotifications: Bool? = nil,
                                           sendCheckInCommentNotifications: Bool? = nil) async
    {
        do {
            let updatedSettings = try await repository.profile.updateSettings(update: .init(
                id: id,
                sendReactionNotifications: sendReactionNotifications,
                sendTaggedCheckInNotifications: sendTaggedCheckInNotifications,
                sendFriendRequestNotifications: sendFriendRequestNotifications,
                sendCommentNotifications: sendCheckInCommentNotifications
            ))
            withAnimation {
                extendedProfile = extendedProfile?.copyWith(settings: updatedSettings)
            }
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to update notification settings. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func logOut() async {
        do {
            try await repository.auth.logOut()
            clearTemporaryData()
            UserDefaults().reset()
        } catch {
            alertError = .init()
            logger.error("Failed to log out. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func deleteCurrentAccount() async {
        do {
            try await repository.profile.deleteCurrentAccount()
            logger.info("User succesfully deleted")
            try await repository.auth.logOut()
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete current account. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func uploadAvatar(data: Data) async {
        guard let extendedProfile else { return }
        do {
            let imageEntity = try await repository.profile.uploadAvatar(userId: extendedProfile.id, data: data)
            self.extendedProfile = extendedProfile.copyWith(avatars: [imageEntity])
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Uploading avatar failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func updateProfile(username: String?, firstName: String?, lastName: String?) async {
        do {
            let updatedProfile = try await repository.profile.update(
                update: .init(id: id, username: username, firstName: firstName, lastName: lastName)
            )
            extendedProfile = updatedProfile
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to update profile. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func onboardingUpdate() async {
        do {
            let updatedProfile = try await repository.profile.update(update: .init(id: id, isOnboarded: true))
            extendedProfile = updatedProfile
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to update profile. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func updatePrivacySettings() async {
        do {
            let updatedProfile = try await repository.profile.update(update: .init(id: id, isPrivate: isPrivateProfile))
            extendedProfile = updatedProfile
            logger.log("Updated privacy settings")
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to update settings. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func updateDisplaySettings() async {
        do {
            let updatedProfile = try await repository.profile.update(update: .init(id: id, showFullName: showFullName))
            extendedProfile = updatedProfile
            logger.log("updated display settings")
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to update profile. Error: \(error) (\(#file):\(#line))")
        }
    }
}
