import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

enum ProfileState: Sendable {
    case loading, populated(Profile.Extended), error([Error])

    static func == (lhs: ProfileState, rhs: ProfileState) -> Bool {
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
final class ProfileModel {
    private let logger = Logger(category: "ProfileModel")
    // Auth state
    var profileState: ProfileState = .loading
    var authState: AuthState?
    var alertError: AlertEvent?

    // Profile Settings
    var showFullName = false
    var isPrivateProfile = true

    // Account Settings
    var email = ""

    // Application Settings
    var notificationSettings: Models.Notification.Settings? {
        get {
            access(keyPath: \.notificationSettings)
            return UserDefaults.read(forKey: .notificationSettingsData)
        }

        set {
            withMutation(keyPath: \.notificationSettings) {
                UserDefaults.set(value: newValue, forKey: .notificationSettingsData)
            }
        }
    }

    // AppIcon
    var appIcon: AppIcon = .ramune

    private let repository: Repository

    var extendedProfile: Profile.Extended? {
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

    var friends: [Friend.Saved] {
        get {
            access(keyPath: \.friends)
            return UserDefaults.read(forKey: .profileFriendsData) ?? []
        }

        set {
            withMutation(keyPath: \.friends) {
                UserDefaults.set(value: newValue, forKey: .profileFriendsData)
            }
        }
    }

    var roles: [Role.Name] {
        get {
            access(keyPath: \.roles)
            return UserDefaults.read(forKey: .profileRolesData) ?? []
        }

        set {
            withMutation(keyPath: \.roles) {
                UserDefaults.set(value: newValue, forKey: .profileRolesData)
            }
        }
    }

    var permissions: [Permission.Name] {
        get {
            access(keyPath: \.permissions)
            return UserDefaults.read(forKey: .profilePermissionsData) ?? []
        }

        set {
            withMutation(keyPath: \.permissions) {
                UserDefaults.set(value: newValue, forKey: .profilePermissionsData)
            }
        }
    }

    init(repository: Repository) {
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
        UIApplication.shared.setAlternateIconName(appIcon == AppIcon.ramune ? nil : appIcon.rawValue)
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
    public func hasPermission(_: Permission.Name) -> Bool {
        permissions.contains(permissions)
    }

    public func hasRole(_ role: Role.Name) -> Bool {
        roles.contains(role)
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
            showFullName = extendedProfile.nameDisplay == .fullName
            isPrivateProfile = extendedProfile.isPrivate
            appIcon = .currentAppIcon
            profileState = .populated(extendedProfile)
            logger.info("Profile data optimistically initialized based on previously stored data, refreshing...")
        }

        let deviceToken = await DeviceTokenActor.shared.deviceTokenForPusNotifications
        guard let deviceToken else {
            logger.error("Failed to obtain device token")
            return
        }
        let startTime = DispatchTime.now()
        async let profilePromise = repository.profile.getCurrentUser()
        async let userPromise = repository.auth.getUser()
        async let friendsPromise = repository.friend.getCurrentUserFriends()
        async let pushNotificationSettingsPromise = repository.notification.refreshPushNotificationToken(deviceToken: deviceToken, isDebug: false)

        var errors = [Error]()
        do {
            let (currentUserProfile, userResult, friendsResult, pushNotificationSettings) = try await (profilePromise, userPromise, friendsPromise, pushNotificationSettingsPromise)
            extendedProfile = currentUserProfile
            showFullName = currentUserProfile.nameDisplay == .fullName
            isPrivateProfile = currentUserProfile.isPrivate
            notificationSettings = .init(profileSettings: currentUserProfile.settings, pushNotificationSettings: pushNotificationSettings)
            friends = friendsResult
            appIcon = .currentAppIcon
            email = userResult.email.orEmpty
            roles = userResult.roles
            permissions = userResult.permissions
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
            let imageEntity = try await repository.profile.uploadAvatar(id: extendedProfile.id, data: data)
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

    // Friends

    public var acceptedFriends: [Profile.Saved] {
        guard let extendedProfile else { return [] }
        return friends.filter { $0.status == .accepted }.compactMap { $0.getFriend(userId: extendedProfile.id) }
    }

    public var blockedUsers: [Friend.Saved] {
        friends.filter { $0.status == .blocked }
    }

    public var acceptedOrPendingFriends: [Friend.Saved] {
        friends.filter { $0.status != .blocked }
    }

    public var pendingFriends: [Friend.Saved] {
        friends.filter { $0.status == .pending }
    }

    public func sendFriendRequest(receiver: Profile.Id, onSuccess: (() -> Void)? = nil) async {
        do {
            let newFriend = try await repository.friend.insert(newFriend: Friend.NewRequest(receiver: receiver, status: .pending))
            withAnimation {
                self.friends.append(newFriend)
            }
            if let onSuccess {
                onSuccess()
            }
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed add new friend '\(receiver)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func updateFriendRequest(friend: Friend.Saved, newStatus: Friend.Status) async {
        do {
            let updatedFriend = try await repository.friend.update(id: friend.id, friendUpdate: .init(
                sender: friend.sender,
                receiver: friend.receiver,
                status: newStatus
            ))
            withAnimation {
                self.friends.replace(friend, with: updatedFriend)
            }
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error(
                "Failed to update friend request. Error: \(error) (\(#file):\(#line))"
            )
        }
    }

    public func removeFriendRequest(_ friend: Friend.Saved) async {
        do {
            try await repository.friend.delete(id: friend.id)
            withAnimation {
                self.friends.remove(object: friend)
            }
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to remove friend request '\(friend.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func hasNoFriendStatus(friend: Profile.Saved) -> Bool {
        guard let extendedProfile else { return false }
        return !friends.contains(where: { $0.getFriend(userId: extendedProfile.id).id == friend.id })
    }

    public func isFriend(_ friend: Profile.Saved) -> Bool {
        guard let extendedProfile else { return false }
        return friends.contains(where: { $0.status == .accepted && $0.getFriend(userId: extendedProfile.id).id == friend.id })
    }

    public func isPendingUserApproval(_ friend: Profile.Saved) -> Friend.Saved? {
        guard let extendedProfile else { return nil }
        return friends.first(where: { $0.status == .pending && $0.getFriend(userId: extendedProfile.id).id == friend.id })
    }

    public func isPendingCurrentUserApproval(_ friend: Profile.Saved) -> Friend.Saved? {
        friends.first(where: { $0.status == .pending && $0.sender == friend })
    }

    public func refreshFriends(withHaptics _: Bool = false) async {
        do {
            friends = try await repository.friend.getCurrentUserFriends()
        } catch {
            logger.error("Failed to load friends for current user. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func unblockUser(_ friend: Friend.Saved) async {
        do {
            try await repository.friend.delete(id: friend.id)
            withAnimation {
                self.friends.remove(object: friend)
            }
            logger.notice("\(friend.id) unblocked")
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to unblock user \(friend.id). Error: \(error) (\(#file):\(#line))")
        }
    }

    public func blockUser(user: Profile.Saved, onSuccess: @escaping () -> Void) async {
        guard let extendedProfile else { return }
        if let friend = friends.first(where: { $0.getFriend(userId: extendedProfile.id) == user }) {
            await updateFriendRequest(friend: friend, newStatus: Friend.Status.blocked)
        } else {
            do {
                let blockedUser = try await repository.friend.insert(newFriend: .init(receiver: user.id, status: .blocked))
                withAnimation {
                    self.friends.append(blockedUser)
                }
                onSuccess()
            } catch {
                guard !error.isCancelled else { return }
                alertError = .init()
                logger.error("Failed to block user \(user.id). Error: \(error) (\(#file):\(#line))")
            }
        }
    }

    // Notifications

    public func updatePushNotificationSettingsForDevice(reactions: Models.Notification.DeliveryType? = nil,
                                                        taggedCheckIn: Models.Notification.DeliveryType? = nil,
                                                        friendRequest: Models.Notification.DeliveryType? = nil,
                                                        checkInComment: Models.Notification.DeliveryType? = nil) async
    {
        guard let notificationSettings else {
            logger.error("Can not update notification settings before initialization")
            return
        }
        let updatedNotificationSettings = notificationSettings.copyWith(
            reactions: reactions,
            taggedCheckIn: taggedCheckIn,
            friendRequest: friendRequest,
            checkInComment: checkInComment
        )
        do {
            try await repository.notification.updateNotificationSettings(settings: updatedNotificationSettings)
            self.notificationSettings = updatedNotificationSettings
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to update push notification settings for device. Error: \(error) (\(#file):\(#line))")
        }
    }
}

public func clearTemporaryData() {
    let logger = Logger(category: "TempDataCleanUp")
    let fileManager = FileManager.default
    do {
        let directoryContents = try fileManager.contentsOfDirectory(
            at: URL.cachesDirectory,
            includingPropertiesForKeys: nil,
            options: []
        )
        for file in directoryContents {
            try fileManager.removeItem(at: file)
        }
    } catch {
        logger.error("Failed to clear the app folder. Error: \(error) (\(#file):\(#line))")
    }
}
