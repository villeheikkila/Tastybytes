import SwiftUI

@MainActor class ProfileManager: ObservableObject {
  private let logger = getLogger(category: "ProfileManager")
  let client: Client
  @Published private(set) var isLoggedIn = false
  @Published private(set) var colorScheme: ColorScheme?
  @Published private(set) var friends = [Profile]()

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

  func refresh() {
    Task {
      switch await client.profile.getCurrentUser() {
      case let .success(currentUserProfile):
        self.profile = currentUserProfile
        setPreferredColorScheme(settings: currentUserProfile.settings)
        self.isLoggedIn = true
        loadFriends()
      case let .failure(error):
        logger.error("error while loading current user profile: \(error.localizedDescription)")
        self.isLoggedIn = false
        _ = await client.auth.logOut()
      }
    }
  }

  func hasPermission(_ permission: PermissionName) -> Bool {
    guard let roles = profile?.roles else { return false }
    let permissions = roles.flatMap(\.permissions)
    return permissions.contains(where: { $0.name == permission })
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

  func loadFriends() {
    Task {
      switch await client.friend.getByUserId(userId: getId(), status: nil) {
      case let .success(friends):
        self.friends = friends.map { $0.getFriend(userId: getId()) }
      case let .failure(error):
        logger.error("failed to load friends for user \(self.getId()): \(error.localizedDescription)")
      }
    }
  }

  func hasFriendByUserId(userId: UUID) -> Bool {
    friends.contains(where: { $0.id == userId })
  }

  func sendFriendRequest(receiver: UUID, onSuccess: @escaping () -> Void) {
    Task {
      switch await client.friend.insert(newFriend: Friend.NewRequest(receiver: receiver, status: .pending)) {
      case let .success(newFriend):
        self.friends.append(newFriend.receiver)
        onSuccess()
      case let .failure(error):
        logger
          .error(
            "failed to send friend request to \(receiver.uuidString.lowercased()): \(error.localizedDescription)"
          )
      }
    }
  }
}
