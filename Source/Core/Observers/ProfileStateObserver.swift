import EnvironmentModels
import SwiftUI

@MainActor
struct ProfileStateObserver<Content: View>: View {
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        switch profileEnvironmentModel.profileState {
        case .populated:
            content()
                .task {
                    await friendEnvironmentModel.initialize(profile: profileEnvironmentModel.profile)
                }
        case .loading:
            EmptyView()
        case let .error(errors):
            AppErrorStateView(errors: errors)
        }
    }
}
