import SwiftUI
import Realtime

class CurrentProfile: ObservableObject {
    @Published var profile: Profile?
    
    func get(id: UUID) {
        Task {
            do {
                let currentUserProfile = try await repository.profile.getById(id: id)
                await MainActor.run {
                    self.profile = currentUserProfile
                }
            } catch {
                print("error while loading profile: \(error.localizedDescription)")
                try await repository.auth.logOut()
            }
        }
    }
    
    func refresh() {
        if let id = profile?.id {
            Task {
                do {
                    let currentUserProfile = try await repository.profile.getById(id: id)
                    await MainActor.run {
                        self.profile = currentUserProfile
                    }
                } catch {
                    print("error while loading profile: \(error)")
                }
            }
        }
    }
    
    func hasPermission(_ permission: PermissionName) -> Bool {
        if let roles = profile?.roles {
            let permissions = roles.flatMap { $0.permissions }
            return permissions.contains(where: { $0.name == permission})
        } else {
            return false
        }
    }
}

public struct CurrentProfileProviderView<RootView: View>: View {
    @StateObject var currentProfile = CurrentProfile()
    @StateObject var notificationManager = NotificationManager()

    let userId: UUID
    let rootView: () -> RootView
    
    public init(
        userId: UUID,
        @ViewBuilder rootView: @escaping () -> RootView
    ) {
        self.rootView = rootView
        self.userId = userId
    }
    
    func getColorScheme(colorScheme: ProfileSettings.ColorScheme?) -> ColorScheme? {
        if let colorScheme = colorScheme {
            switch colorScheme {
            case ProfileSettings.ColorScheme.dark: return SwiftUI.ColorScheme.dark
            case ProfileSettings.ColorScheme.light: return SwiftUI.ColorScheme.light
            case ProfileSettings.ColorScheme.system: return nil
            }
        } else {
            return nil
        }
    }
    
    public var body: some View {
        rootView()
            .environmentObject(currentProfile)
            .environmentObject(notificationManager)
            .task {
                currentProfile.get(id: repository.auth.getCurrentUserId())
                notificationManager.getAll()
            }
            .preferredColorScheme(getColorScheme(colorScheme: currentProfile.profile?.settings?.colorScheme))
    }
}

struct WithProfile<Content: View>: View {
    @EnvironmentObject var currentProfile: CurrentProfile
    
    let content: (_ profile: Profile) -> Content
    
    public init(
        @ViewBuilder content: @escaping (Profile) -> Content
    ) {
        self.content = content
    }
    
    var body: some View {
        VStack {
            if let profile = currentProfile.profile {
                content(profile)
            } else {
                EmptyView()
            }
        }
    }
}
