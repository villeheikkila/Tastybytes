import SwiftUI

class CurrentProfile: ObservableObject {
    @Published  var profile: Profile?

    func get(id: UUID) {
        Task {
            do {
                let currentUserProfile = try await repository.profile.getById(id: id)
                DispatchQueue.main.async {
                    self.profile = currentUserProfile
                }
            } catch {
                print("error while loading profile: \(error)")
            }
        }
    }
}

public struct CurrentProfileProviderView<RootView: View>: View {
    @StateObject var currentProfile = CurrentProfile()
    let userId: UUID
    let rootView: () -> RootView

    public init(
        userId: UUID,
        @ViewBuilder rootView: @escaping () -> RootView
    ) {
        self.rootView = rootView
        self.userId = userId
    }

    public var body: some View {
        rootView()
            .environmentObject(currentProfile)
            .task {
                currentProfile.get(id: repository.auth.getCurrentUserId())
            }
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
