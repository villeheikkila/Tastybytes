import Components
import EnvironmentModels
import SwiftUI

@MainActor
struct AppErrorStateView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let errors: [Error]

    var title: LocalizedStringKey {
        if errors.isNetworkUnavailable {
            "app.error.networkUnavailable.title"
        } else {
            "app.error.unexpected.title"
        }
    }

    var description: Text {
        if errors.isNetworkUnavailable {
            Text("app.error.networkUnavailable.description")
        } else {
            Text("app.error.unexpected.description")
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
            await appEnvironmentModel.initialize(reset: true)
        })
    }
}
