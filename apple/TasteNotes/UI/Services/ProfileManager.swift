import SwiftUI

class ProfileManager: ObservableObject {
    private var profile: Profile.Extended?
    var isLoggedIn = false
    @Published var colorScheme: ColorScheme?

    func get() -> Profile.Extended {
        if let profile = profile {
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
                await MainActor.run {
                    self.profile = currentUserProfile
                    setPreferredColorScheme(settings: currentUserProfile.settings)
                    self.isLoggedIn = true
                    
                }
            case let .failure(error):
                print("error while loading profile: \(error.localizedDescription)")
                self.isLoggedIn = false
                _ = await repository.auth.logOut()
            }
        }
    }

    func hasPermission(_ permission: PermissionName) -> Bool {
        if let roles = profile?.roles {
            let permissions = roles.flatMap { $0.permissions }
            return permissions.contains(where: { $0.name == permission })
        } else {
            return false
        }
    }

    func setPreferredColorScheme(settings: ProfileSettings) {
        switch settings.colorScheme {
        case ProfileSettings.ColorScheme.dark:
            self.colorScheme = ColorScheme.dark
        case ProfileSettings.ColorScheme.light:
            self.colorScheme = ColorScheme.light
        case ProfileSettings.ColorScheme.system:
            self.colorScheme = nil
        }
    }
}
