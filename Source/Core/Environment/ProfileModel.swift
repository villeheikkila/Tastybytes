import Extensions
import Logging
import Models
import PhotosUI
import Repositories
import StoreKit
import SwiftUI
import Tagged

enum ProfileState: Sendable, Equatable {
    case loading, populated(Profile.Populated), error(Error), unauthenticated

    static func == (lhs: ProfileState, rhs: ProfileState) -> Bool {
        switch (lhs, rhs) {
        case let (.populated(lhsProfile), .populated(rhsProfile)):
            lhsProfile == rhsProfile
        case (.loading, .loading):
            true
        case let (.error(lhsError), .error(rhsError)):
            lhsError.localizedDescription == rhsError.localizedDescription
        default:
            false
        }
    }

    var isPopulated: Bool {
        if case .populated = self {
            return true
        }
        return false
    }
}

extension Profile {
    struct Populated: Equatable, Codable {
        let id: Profile.Id
        let username: String?
        let firstName: String?
        let lastName: String?
        let preferredName: String
        let joinedAt: Date
        let isPrivate: Bool
        let isOnboarded: Bool
        let nameDisplay: Profile.NameDisplay
        let notificationSettings: Models.Notification.Settings
        let avatars: [ImageEntity.Saved]
        let email: String?
        let roles: [Role.Name]
        let permissions: [Permission.Name]
        let friends: [Friend.Saved]
        // meta
        let version: Int
        let updatedAt: Date

        func copyWith(
            id: Profile.Id? = nil,
            username: String? = nil,
            firstName: String? = nil,
            lastName: String? = nil,
            preferredName: String? = nil,
            joinedAt: Date? = nil,
            isPrivate: Bool? = nil,
            isOnboarded: Bool? = nil,
            nameDisplay: Profile.NameDisplay? = nil,
            notificationSettings: Models.Notification.Settings? = nil,
            avatars: [ImageEntity.Saved]? = nil,
            email: String?? = nil,
            roles: [Role.Name]? = nil,
            permissions: [Permission.Name]? = nil,
            friends: [Friend.Saved]? = nil
        ) -> Self {
            .init(
                id: id ?? self.id,
                username: username ?? self.username,
                firstName: firstName ?? self.firstName,
                lastName: lastName ?? self.lastName,
                preferredName: preferredName ?? self.preferredName,
                joinedAt: joinedAt ?? self.joinedAt,
                isPrivate: isPrivate ?? self.isPrivate,
                isOnboarded: isOnboarded ?? self.isOnboarded,
                nameDisplay: nameDisplay ?? self.nameDisplay,
                notificationSettings: notificationSettings ?? self.notificationSettings,
                avatars: avatars ?? self.avatars,
                email: email ?? self.email,
                roles: roles ?? self.roles,
                permissions: permissions ?? self.permissions,
                friends: friends ?? self.friends,
                version: version,
                updatedAt: Date.now
            )
        }

        var saved: Profile.Saved {
            .init(
                id: id,
                preferredName: preferredName,
                isPrivate: isPrivate,
                joinedAt: joinedAt,
                avatars: avatars
            )
        }
    }
}

extension Profile.Populated {
    init(
        profile: Profile.Extended,
        account: Profile.Account,
        pushNotificationSettings: Profile.PushNotificationSettings,
        friends: [Friend.Saved],
        version: Int
    ) {
        id = profile.id
        username = profile.username
        firstName = profile.firstName
        lastName = profile.lastName
        preferredName = profile.preferredName
        joinedAt = profile.joinedAt
        isPrivate = profile.isPrivate
        isOnboarded = profile.isOnboarded
        nameDisplay = profile.nameDisplay
        notificationSettings = .init(profileSettings: profile.settings, pushNotificationSettings: pushNotificationSettings)
        avatars = profile.avatars
        email = account.email
        roles = account.roles
        permissions = account.permissions
        self.friends = friends
        self.version = version
        updatedAt = Date.now
    }

    init() {
        id = .init()
        username = nil
        firstName = nil
        lastName = nil
        preferredName = ""
        joinedAt = Date.now
        isPrivate = false
        isOnboarded = false
        nameDisplay = .username
        notificationSettings = .init()
        avatars = []
        email = nil
        roles = []
        permissions = []
        friends = []
        version = 0
        updatedAt = Date.now
    }
}

enum ProfileError: Error {
    case failedToObtainDeviceToken
    case failedToObtainSession
}

@MainActor
@Observable
final class ProfileModel {
    private let logger = Logger(label: "ProfileModel")
    private let dataVersion = 1
    // state
    var state: ProfileState = .loading {
        didSet {
            if case let .populated(profile) = state {
                try? storage.save(profile)
            }
        }
    }

    // subscriptions
    let productSubscription = ProductSubscription()
    private var activeTransactions: Set<StoreKit.Transaction> = []
    var subscriptionStatus: SubscriptionStatus = .notSubscribed
    var isProMember = false
    var isRegularMember: Bool {
        !isProMember
    }

    // notifications
    var isRefreshingNotifications = false
    var task: Task<Void, Never>?
    var notifications = [Models.Notification.Joined]()
    var unreadCount: Int = 0
    var deviceToken: Tagged<DeviceToken, String>?
    // app icon
    var appIcon: AppIcon = .ramune
    // dependencies
    private let repository: Repository
    private let storage: any StorageProtocol<Profile.Populated>
    private let onSnack: OnSnack
    private let isDebug: Bool
    // init
    init(repository: Repository, isDebug: Bool, storage: any StorageProtocol<Profile.Populated>, onSnack: @escaping OnSnack) {
        self.repository = repository
        self.isDebug = isDebug
        self.onSnack = onSnack
        self.storage = storage
    }

    func initialize(cache: Bool) async {
        logger.notice("Initializing profile data")
        let startTime = DispatchTime.now()
        let initialValue = cache ? try? storage.load() : nil
        let userId = try? await repository.auth.getUserId()
        if userId == nil {
            state = .error(ProfileError.failedToObtainSession)
            return
        }
        if let initialValue {
            logger.notice("Initializing profile from cache...")
            if initialValue.id != userId {
                logger.notice("Stored profile data is for another user, clearing...")
                try? storage.clear()
            } else if initialValue.version != dataVersion {
                logger.notice("Profile cache version mismatch, ignoring initial value")
            } else {
                state = .populated(initialValue)
                logger.notice("Profile initialized from cache, refreshing...")
            }
        }
        appIcon = .currentAppIcon
        let deviceToken = await DeviceTokenActor.shared.deviceTokenForPusNotifications
        guard let deviceToken else {
            logger.error("Failed to obtain device token")
            state = .error(ProfileError.failedToObtainDeviceToken)
            return
        }
        async let profilePromise = repository.profile.getCurrentUser()
        async let userPromise = repository.auth.getUser()
        async let friendsPromise = repository.friend.getCurrentUserFriends()
        async let pushNotificationSettingsPromise = repository.notification.refreshPushNotificationToken(
            deviceToken: deviceToken,
            isDebug: isDebug
        )
        do {
            let (currentUserProfile, userResult, friendsResult, pushNotificationSettings) = try await (profilePromise, userPromise, friendsPromise, pushNotificationSettingsPromise)
            notifications = currentUserProfile.notifications.sorted { $0.createdAt > $1.createdAt }
            unreadCount = currentUserProfile.notifications.count { $0.seenAt == nil }
            state = .populated(.init(
                profile: currentUserProfile,
                account: userResult,
                pushNotificationSettings: pushNotificationSettings,
                friends: friendsResult,
                version: dataVersion
            ))
            self.deviceToken = deviceToken
            logger.info("Profile refreshed in \(startTime.elapsedTime())ms")
        } catch {
            logger.error("Error while loading current user profile. Error: \(error) (\(#file):\(#line))")
            if error.isNetworkUnavailable, state.isPopulated {
                logger.notice("Network unavailable, keeping current profile state")
                return
            }
            state = .error(error)
        }
    }

    // session
    func listenToAuthState() async {
        do {
            for await state in try await repository.auth.authStateListener() {
                logger.info("Auth state changed to \(String(describing: state))")
                if state == .authenticated {
                    await initialize(cache: true)
                } else {
                    self.state = .unauthenticated
                }
                if Task.isCancelled {
                    logger.info("Auth state listener cancelled")
                    return
                }
            }
        } catch {
            state = .unauthenticated
            logger.error("Error while listening to auth state. Error: \(error) (\(#file):\(#line))")
        }
    }

    func loadSessionFromURL(url: URL) async {
        do {
            try await repository.auth.signInFromUrl(url: url)
        } catch {
            logger.error("Failed to load session from url: \(url). Error: \(error) (\(#file):\(#line))")
        }
    }

    // app icon
    func setAppIcon(_ appIcon: AppIcon) {
        UIApplication.shared.setAlternateIconName(appIcon == AppIcon.ramune ? nil : appIcon.rawValue)
        self.appIcon = appIcon
    }

    // Getters that are only available after authentication
    var profile: Profile.Saved {
        if case let .populated(extendedProfile) = state {
            return extendedProfile.saved
        } else {
            logger.error("profile can only be used on authenticated routes.")
            return .init(id: .init(), preferredName: nil, isPrivate: false, joinedAt: Date.now, avatars: [])
        }
    }

    var id: Profile.Id {
        if case let .populated(extendedProfile) = state {
            return extendedProfile.id
        } else {
            logger.error("id can only be used on authenticated routes.")
            return .init()
        }
    }

    var email: String {
        if case let .populated(extendedProfile) = state {
            return extendedProfile.email ?? ""
        } else {
            logger.error("email can only be used on authenticated routes.")
            return ""
        }
    }

    var username: String {
        if case let .populated(extendedProfile) = state {
            return extendedProfile.username ?? ""
        } else {
            logger.error("username can only be used on authenticated routes.")
            return ""
        }
    }

    var firstName: String? {
        if case let .populated(extendedProfile) = state {
            return extendedProfile.firstName
        } else {
            logger.error("username can only be used on authenticated routes.")
            return nil
        }
    }

    var lastName: String? {
        if case let .populated(extendedProfile) = state {
            return extendedProfile.lastName
        } else {
            logger.error("username can only be used on authenticated routes.")
            return nil
        }
    }

    var isOnboarded: Bool {
        if case let .populated(extendedProfile) = state {
            return extendedProfile.isOnboarded
        }
        return false
    }

    var isPrivateProfile: Bool {
        if case let .populated(extendedProfile) = state {
            return extendedProfile.isPrivate
        }
        return false
    }

    var showFullName: Bool {
        guard case let .populated(extendedProfile) = state else { return false }
        return extendedProfile.nameDisplay == .fullName
    }

    var notificationSettings: Models.Notification.Settings {
        guard case let .populated(extendedProfile) = state else { return .init() }
        return extendedProfile.notificationSettings
    }

    // Access Control
    func hasPermission(_ permission: Permission.Name) -> Bool {
        if case let .populated(extendedProfile) = state {
            return extendedProfile.permissions.contains(permission)
        }
        return false
    }

    func hasRole(_ role: Role.Name) -> Bool {
        if case let .populated(extendedProfile) = state {
            return extendedProfile.roles.contains(role)
        }
        return false
    }

    func hasChanged(username: String, firstName: String, lastName: String) -> Bool {
        guard case let .populated(extendedProfile) = state else { return false }
        return !(username == extendedProfile.username &&
            firstName == extendedProfile.firstName ?? "" &&
            lastName == extendedProfile.lastName ?? "")
    }

    func checkIfUsernameIsAvailable(username: String) async -> Bool {
        do {
            return try await repository.profile.checkIfUsernameIsAvailable(username: username)
        } catch {
            logger.error("Failed to check if username is available. Error: \(error) (\(#file):\(#line))")
            return false
        }
    }

    func logOut() async {
        do {
            try await repository.auth.logOut()
            clearTemporaryData()
            UserDefaults().reset()
        } catch {
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Unexpected error occurred while logging out")))
            logger.error("Failed to log out. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteCurrentAccount() async {
        do {
            try await repository.profile.deleteCurrentAccount()
            logger.info("User succesfully deleted")
            try await repository.auth.logOut()
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Unexpected error occurred while deleting account")))
            logger.error("Failed to delete current account. Error: \(error) (\(#file):\(#line))")
        }
    }

    func uploadAvatar(data: Data) async {
        guard case let .populated(extendedProfile) = state else { return }
        do {
            let imageEntity = try await repository.profile.uploadAvatar(id: extendedProfile.id, data: data)
            state = .populated(extendedProfile.copyWith(avatars: [imageEntity]))
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Unexpected error occurred while uploading avatar")))
            logger.error("Uploading avatar failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteAvatar(entity: ImageEntity.Saved) async {
        guard case let .populated(extendedProfile) = state else { return }
        do {
            try await repository.imageEntity.delete(from: .avatars, id: entity.id)
            withAnimation {
                self.state =
                    .populated(extendedProfile.copyWith(avatars: extendedProfile.avatars.removing(entity)))
            }
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Unexpected error occurred while deleting avatar")))
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }

    func updateProfile(username: String?, firstName: String?, lastName: String?) async {
        guard case let .populated(extendedProfile) = state else { return }
        do {
            let updatedProfile = try await repository.profile.update(
                update: .init(id: id, username: username, firstName: firstName, lastName: lastName)
            )
            state = .populated(extendedProfile.copyWith(
                username: updatedProfile.username,
                firstName: updatedProfile.firstName,
                lastName: updatedProfile.lastName
            ))
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Unexpected error occurred while updating profile")))
            logger.error("Failed to update profile. Error: \(error) (\(#file):\(#line))")
        }
    }

    func onboardingUpdate() async {
        guard case let .populated(extendedProfile) = state else { return }
        do {
            let updatedProfile = try await repository.profile.update(update: .init(id: id, isOnboarded: true))
            state = .populated(extendedProfile.copyWith(isOnboarded: updatedProfile.isOnboarded))
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Unexpected error occurred while updating onboarding status")))
            logger.error("Failed to update profile. Error: \(error) (\(#file):\(#line))")
        }
    }

    func updatePrivacySettings(isPrivate: Bool) async {
        guard case let .populated(extendedProfile) = state else { return }
        do {
            let updatedProfile = try await repository.profile.update(update: .init(id: id, isPrivate: isPrivate))
            state = .populated(extendedProfile.copyWith(isPrivate: updatedProfile.isPrivate))
            logger.info("Updated privacy settings")
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Unexpected error occurred while updating privacy settings")))
            logger.error("Failed to update settings. Error: \(error) (\(#file):\(#line))")
        }
    }

    func updateDisplaySettings(showFullName: Bool) async {
        guard case let .populated(extendedProfile) = state else { return }
        do {
            let updatedProfile = try await repository.profile.update(update: .init(id: id, showFullName: showFullName))
            state = .populated(extendedProfile.copyWith(nameDisplay: updatedProfile.nameDisplay))
            logger.info("updated display settings")
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Unexpected error occurred while updating display settings")))
            logger.error("Failed to update profile. Error: \(error) (\(#file):\(#line))")
        }
    }

    // Friends
    var friends: [Friend.Saved] {
        guard case let .populated(extendedProfile) = state else { return [] }
        return extendedProfile.friends
    }

    var acceptedFriends: [Profile.Saved] {
        guard case let .populated(extendedProfile) = state else { return [] }
        return friends.filter { $0.status == .accepted }.compactMap { $0.getFriend(userId: extendedProfile.id) }
    }

    var blockedUsers: [Friend.Saved] {
        friends.filter { $0.status == .blocked }
    }

    var acceptedOrPendingFriends: [Friend.Saved] {
        friends.filter { $0.status != .blocked }
    }

    var pendingFriends: [Friend.Saved] {
        friends.filter { $0.status == .pending }
    }

    func sendFriendRequest(receiver: Profile.Id, onSuccess: (() -> Void)? = nil) async {
        guard case let .populated(extendedProfile) = state else { return }
        do {
            let newFriend = try await repository.friend.insert(newFriend: Friend.NewRequest(receiver: receiver, status: .pending))
            withAnimation {
                self.state = .populated(extendedProfile.copyWith(friends: friends + [newFriend]))
            }
            if let onSuccess {
                onSuccess()
            }
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Unexpected error occurred while sending friend request")))
            logger.error("Failed add new friend '\(receiver)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func updateFriendRequest(friend: Friend.Saved, newStatus: Friend.Status) async {
        guard case let .populated(extendedProfile) = state else { return }
        do {
            let updatedFriend = try await repository.friend.update(id: friend.id, friendUpdate: .init(
                sender: friend.sender,
                receiver: friend.receiver,
                status: newStatus
            ))
            withAnimation {
                self.state = .populated(extendedProfile.copyWith(friends: friends.replacing(friend, with: updatedFriend)))
            }
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Unexpected error occurred while updating friend request")))
            logger.error(
                "Failed to update friend request. Error: \(error) (\(#file):\(#line))"
            )
        }
    }

    func removeFriendRequest(_ friend: Friend.Saved) async {
        guard case let .populated(extendedProfile) = state else { return }
        do {
            try await repository.friend.delete(id: friend.id)
            withAnimation {
                self.state = .populated(extendedProfile.copyWith(friends: friends.removing(friend)))
            }
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Unexpected error occurred while removing friend request")))
            logger.error("Failed to remove friend request '\(friend.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func hasNoFriendStatus(friend: Profile.Saved) -> Bool {
        guard case let .populated(extendedProfile) = state else { return false }
        return !friends.contains(where: { $0.getFriend(userId: extendedProfile.id).id == friend.id })
    }

    func isFriend(_ friend: Profile.Saved) -> Bool {
        guard case let .populated(extendedProfile) = state else { return false }
        return friends.contains(where: { $0.status == .accepted && $0.getFriend(userId: extendedProfile.id).id == friend.id })
    }

    func isPendingUserApproval(_ friend: Profile.Saved) -> Friend.Saved? {
        guard case let .populated(extendedProfile) = state else { return nil }
        return friends.first(where: { $0.status == .pending && $0.getFriend(userId: extendedProfile.id).id == friend.id })
    }

    func isPendingCurrentUserApproval(_ friend: Profile.Saved) -> Friend.Saved? {
        friends.first(where: { $0.status == .pending && $0.sender == friend })
    }

    func refreshFriends(withHaptics _: Bool = false) async {
        guard case let .populated(extendedProfile) = state else { return }
        do {
            let friends = try await repository.friend.getCurrentUserFriends()
            state = .populated(extendedProfile.copyWith(friends: friends))
        } catch {
            logger.error("Failed to load friends for current user. Error: \(error) (\(#file):\(#line))")
        }
    }

    func unblockUser(_ friend: Friend.Saved) async {
        guard case let .populated(extendedProfile) = state else { return }
        do {
            try await repository.friend.delete(id: friend.id)
            withAnimation {
                self.state = .populated(extendedProfile.copyWith(friends: friends.removing(friend)))
            }
            logger.notice("\(friend.id) unblocked")
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Unexpected error occurred while unblocking user")))
            logger.error("Failed to unblock user \(friend.id). Error: \(error) (\(#file):\(#line))")
        }
    }

    func blockUser(user: Profile.Saved, onSuccess: @escaping () -> Void) async {
        guard case let .populated(extendedProfile) = state else { return }
        if let friend = friends.first(where: { $0.getFriend(userId: extendedProfile.id) == user }) {
            await updateFriendRequest(friend: friend, newStatus: Friend.Status.blocked)
        } else {
            do {
                let blockedUser = try await repository.friend.insert(newFriend: .init(receiver: user.id, status: .blocked))
                withAnimation {
                    self.state = .populated(extendedProfile.copyWith(friends: friends + [blockedUser]))
                }
                onSuccess()
            } catch {
                guard !error.isCancelled else { return }
                onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Unexpected error occurred while blocking user")))
                logger.error("Failed to block user \(user.id). Error: \(error) (\(#file):\(#line))")
            }
        }
    }

    // Notifications

    func updatePushNotificationSettingsForDevice(reactions: Models.Notification.DeliveryType? = nil,
                                                 taggedCheckIn: Models.Notification.DeliveryType? = nil,
                                                 friendRequest: Models.Notification.DeliveryType? = nil,
                                                 checkInComment: Models.Notification.DeliveryType? = nil) async
    {
        guard case let .populated(extendedProfile) = state else { return }
        let updatedNotificationSettings = notificationSettings.copyWith(
            reactions: reactions,
            taggedCheckIn: taggedCheckIn,
            friendRequest: friendRequest,
            checkInComment: checkInComment
        )
        do {
            try await repository.notification.updateNotificationSettings(settings: updatedNotificationSettings)
            state = .populated(extendedProfile.copyWith(notificationSettings: updatedNotificationSettings))
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Unexpected error occurred while updating push notification settings")))
            logger.error("Failed to update push notification settings for device. Error: \(error) (\(#file):\(#line))")
        }
    }

    // subscriptions
    func onTaskStatusChange(taskStatus: EntitlementTaskState<[StoreKit.Product.SubscriptionInfo.Status]>, productSubscriptions _: [SubscriptionProduct]) async {
        if let value = taskStatus.value {
            let isPro = !value
                .filter { $0.state != .revoked && $0.state != .expired }
                .isEmpty
            isProMember = isPro
            logger.info("User is a \(isPro ? "pro" : "regular") member")
        }
    }

    func onInAppPurchaseCompletion(product: StoreKit.Product, result: Result<StoreKit.Product.PurchaseResult, Error>) async {
        switch result {
        case let .success(result):
            await onPurchaseResult(product: product, result: result)
        case let .failure(error):
            logger.error("Purchase failed: \(error)")
        }
    }

    func onPurchaseResult(product: StoreKit.Product, result: StoreKit.Product.PurchaseResult) async {
        switch result {
        case let .success(transaction):
            logger.info("Purchases for \(product.displayName) successful at \(transaction.signedDate)")
            if let transaction = try? transaction.payloadValue {
                activeTransactions.insert(transaction)
                await transaction.finish()
            }
        case .pending:
            logger.info("Purchases for \(product.displayName) pending user action")
        case .userCancelled:
            logger.info("Purchases for \(product.displayName) was cancelled by the user")
        @unknown default:
            logger.error("Encountered unknown purchase result")
        }
    }

    // notifications
    var unreadFriendRequestCount: Int {
        notifications
            .filter { notification in
                switch notification.content {
                case .friendRequest where notification.seenAt == nil:
                    true
                default:
                    false
                }
            }
            .count
    }

    func getUnreadCount() async {
        guard case let .populated(extendedProfile) = state else { return }
        do {
            let count = try await repository.notification.getUnreadCount(profileId: extendedProfile.id)
            unreadCount = count
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Unexpected error occurred while getting unread count")))
            logger.error("Failed to get all unread notifications. Error: \(error) (\(#file):\(#line))")
        }
    }

    func refreshNotifications(reset: Bool = false, withHaptics: Bool = false) {
        guard case let .populated(extendedProfile) = state else { return }
        guard task == nil else {
            logger.info("Tried to refresh but already fetching notifications. Skipping.")
            return
        }
        task = Task {
            defer { task = nil }
            if withHaptics {
                isRefreshingNotifications = true
            }
            do {
                let newNotifications = try await repository.notification.getAll(
                    profileId: extendedProfile.id,
                    afterId: reset ? nil : notifications.first?.id
                )
                if reset {
                    notifications = newNotifications
                    unreadCount = newNotifications.count { $0.seenAt == nil }
                } else {
                    notifications.insert(contentsOf: newNotifications, at: 0)
                }
            } catch {
                guard !error.isCancelled else { return }
                logger.error("Failed to refresh notifications. Error: \(error) (\(#file):\(#line))")
            }
            if withHaptics {
                isRefreshingNotifications = false
            }
        }
    }

    func deleteAllNotifications() async {
        do {
            try await repository.notification.deleteAll(profileId: id)
            notifications = [Models.Notification.Joined]()
            unreadCount = 0
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Unexpected error occurred while deleting all notifications")))
            logger.error("Failed to delete all notifications. Error: \(error) (\(#file):\(#line))")
        }
    }

    func markAllAsRead() async {
        do {
            let readNotifications = try await repository.notification.markAllRead()
            let markedAsSeenNotifications = notifications.map { notification in
                let readNotification = readNotifications.first(where: { rn in rn.id == notification.id })
                return readNotification ?? notification
            }

            notifications = markedAsSeenNotifications
            unreadCount = 0
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Unexpected error occurred while marking all notifications as read")))
            logger.error("Failed to mark all notifications as read. Error: \(error) (\(#file):\(#line))")
        }
    }

    func markAllFriendRequestsAsRead() async {
        guard notifications.contains(where: \.isFriendRequest) else { return }
        do {
            let updatedNotifications = try await repository.notification.markAllFriendRequestsAsRead()
            notifications = notifications.map { notification in
                updatedNotifications.first { $0.id == notification.id } ?? notification
            }
            unreadCount = notifications.count {
                $0.seenAt == nil
            }
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to mark all friend requests as read. Error: \(error) (\(#file):\(#line))")
        }
    }

    func markCheckInAsRead(id: CheckIn.Id) async {
        let containsCheckIn = notifications.contains {
            if case let .checkInReaction(cir) = $0.content { return cir.checkIn.id == id }
            if case let .taggedCheckIn(tci) = $0.content { return tci.id == id }
            if case let .checkInComment(cic) = $0.content { return cic.checkIn.id == id }
            return false
        }
        guard containsCheckIn else { return }
        do {
            let updatedNotifications = try await repository.notification.markAllCheckInNotificationsAsRead(checkInId: id)
            notifications = notifications.map { notification in
                updatedNotifications.first { $0.id == notification.id } ?? notification
            }
            unreadCount = notifications.count {
                $0.seenAt == nil
            }
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Unexpected error occurred while marking check-in notifactions as read")))
            logger.error("Failed to mark check-in as read \(id). Error: \(error) (\(#file):\(#line))")
        }
    }

    func notificationMarkAsRead(_ notification: Models.Notification.Joined) async {
        do {
            let updatedNotification = try await repository.notification.markRead(id: notification.id)
            notifications.replace(notification, with: updatedNotification)
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Unexpected error occurred while marking notification as read"), onRetry: { await self.notificationMarkAsRead(notification) }))
            logger.error("Failed to mark '\(notification.id)' as read. Error: \(error) (\(#file):\(#line))")
        }
    }

    func notificationMarkAsUnread(_ notification: Models.Notification.Joined) async {
        do {
            let updatedNotification = try await repository.notification.markUnread(id: notification.id)
            notifications.replace(notification, with: updatedNotification)
        } catch {
            guard !error.isCancelled else { return }
            onSnack(
                .init(
                    mode:
                    .snack(
                        tint: .red,
                        systemName: "exclamationmark.triangle.fill",
                        message: "Unexpected error occurred while marking notification as unread"
                    ),
                    onRetry: { await self.notificationMarkAsUnread(notification) }
                )
            )
            logger.error("Failed to mark '\(notification.id)' as unread. Error: \(error) (\(#file):\(#line))")
        }
    }

    func notificationDelete(id: Models.Notification.Id) async {
        do {
            try await repository.notification.delete(id: id)
            notifications = notifications.removingWithId(id)
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Unexpected error occurred while deleting notification")))
            logger.error("Failed to delete notification. Error: \(error) (\(#file):\(#line))")
        }
    }
}

func clearTemporaryData() {
    let logger = Logger(label: "TempDataCleanUp")
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
