import EnvironmentModels
import SwiftUI

@MainActor
struct ProfileStateObserver<Content: View>: View {
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        switch profileEnvironmentModel.profileState {
        case .initialized:
            content()
                .task {
                    await friendEnvironmentModel.initialize(profile: profileEnvironmentModel.profile)
                }
        case .uninitialized:
            EmptyView()
        case .error:
            // TODO: Add proper error page
            AppUnexpectedErrorState()
        }
    }
}
