import EnvironmentModels
import SwiftUI

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
            ProfileErrorStateView(errors: errors)
        }
    }
}

struct ProfileErrorStateView: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    let errors: [Error]

    var title: LocalizedStringKey {
        if errors.isNetworkUnavailable {
            "app.error.networkUnavailable.title"
        } else {
            "profile.error.unexpected.title"
        }
    }

    var description: Text {
        if errors.isNetworkUnavailable {
            Text("app.error.networkUnavailable.description")
        } else {
            Text("profile.error.unexpected.description")
        }
    }

    var systemImage: String {
        if errors.isNetworkUnavailable {
            "wifi.slash"
        } else {
            "exclamationmark.triangle"
        }
    }

    var body: some View {
        FullScreenErrorView(title: title, description: description, systemImage: systemImage, action: {
            await profileEnvironmentModel.initialize()
        })
    }
}
