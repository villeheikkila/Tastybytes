import SwiftUI

struct ProfileErrorStateView: View {
    @Environment(ProfileModel.self) private var profileModel
    let error: Error

    private var title: LocalizedStringKey {
        if error.isNetworkUnavailable {
            "app.error.networkUnavailable.title"
        } else {
            "profile.error.unexpected.title"
        }
    }

    private var description: Text {
        if error.isNetworkUnavailable {
            Text("app.error.networkUnavailable.description")
        } else {
            Text("profile.error.unexpected.description")
        }
    }

    private var systemImage: String {
        if error.isNetworkUnavailable {
            "wifi.slash"
        } else {
            "exclamationmark.triangle"
        }
    }

    var body: some View {
        FullScreenErrorView(title: title, description: description, systemImage: systemImage, action: {
            await profileModel.initialize(cache: false)
        })
    }
}
