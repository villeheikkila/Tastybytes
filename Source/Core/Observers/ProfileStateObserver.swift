
import SwiftUI

struct ProfileStateObserver<Content: View>: View {
    @Environment(FriendModel.self) private var friendModel
    @Environment(AdminModel.self) private var adminModel
    @Environment(ProfileModel.self) private var profileModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        switch profileModel.profileState {
        case let .populated(profile):
            content()
                .task {
                    await friendModel.initialize(profile: profile)
                    if profileModel.hasRole(.admin) {
                        await adminModel.initialize()
                    }
                }
        case .loading:
            EmptyView()
        case let .error(errors):
            ProfileErrorStateView(errors: errors)
        }
    }
}

struct ProfileErrorStateView: View {
    @Environment(ProfileModel.self) private var profileModel
    let errors: [Error]

    private var title: LocalizedStringKey {
        if errors.isNetworkUnavailable {
            "app.error.networkUnavailable.title"
        } else {
            "profile.error.unexpected.title"
        }
    }

    private var description: Text {
        if errors.isNetworkUnavailable {
            Text("app.error.networkUnavailable.description")
        } else {
            Text("profile.error.unexpected.description")
        }
    }

    private var systemImage: String {
        if errors.isNetworkUnavailable {
            "wifi.slash"
        } else {
            "exclamationmark.triangle"
        }
    }

    var body: some View {
        FullScreenErrorView(title: title, description: description, systemImage: systemImage, action: {
            await profileModel.initialize()
        })
    }
}
