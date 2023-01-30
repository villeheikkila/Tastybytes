import SwiftUI

@MainActor class ProfileManager: ObservableObject {
  @Published private(set) var isLoggedIn = false
  @Published private(set) var colorScheme: ColorScheme?
  @Published private(set) var friends = [Profile]()

  private var profile: Profile.Extended?

  func get() -> Profile.Extended {
    if let profile {
      return profile
    } else {
      fatalError("ProfileManager.get() can only be used on authenticated routes.")
    }
  }

  func getProfile() -> Profile {
    if let profile = profile?.getProfile() {
      return profile
    } else {
      fatalError("ProfileManager.getProfile() can only be used on authenticated routes.")
    }
  }

  func getId() -> UUID {
    if let id = profile?.id {
      return id
    } else {
      fatalError("ProfileManager.getProfile() can only be used on authenticated routes.")
    }
  }

  func refresh() {
    Task {
      switch await repository.profile.getCurrentUser() {
      case let .success(currentUserProfile):
        self.profile = currentUserProfile
        setPreferredColorScheme(settings: currentUserProfile.settings)
        self.isLoggedIn = true
        loadFriends()
      case let .failure(error):
        print("error while loading profile: \(error.localizedDescription)")
        self.isLoggedIn = false
        _ = await repository.auth.logOut()
      }
    }
  }

  func hasPermission(_ permission: PermissionName) -> Bool {
    if let roles = profile?.roles {
      let permissions = roles.flatMap(\.permissions)
      return permissions.contains(where: { $0.name == permission })
    } else {
      return false
    }
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
      switch await repository.friend.getByUserId(userId: getId(), status: nil) {
      case let .success(friends):
        self.friends = friends.map { $0.getFriend(userId: getId()) }
      case let .failure(error):
        print(error)
      }
    }
  }

  func hasFriendByUserId(userId: UUID) -> Bool {
    friends.contains(where: { $0.id == userId })
  }

  func sendFriendRequest(receiver: UUID, onSuccess: @escaping () -> Void) {
    Task {
      switch await repository.friend.insert(newFriend: Friend.NewRequest(receiver: receiver, status: .pending)) {
      case let .success(newFriend):
        self.friends.append(newFriend.receiver)
        onSuccess()
      case let .failure(error):
        print(error)
      }
    }
  }
}
