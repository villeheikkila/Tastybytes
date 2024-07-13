import Components
import EnvironmentModels
import SwiftUI

struct AppErrorStateView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let errors: [Error]

    private var title: LocalizedStringKey {
        if errors.isNetworkUnavailable {
            "app.error.networkUnavailable.title"
        } else {
            "app.error.unexpected.title"
        }
    }

    private var description: Text {
        if errors.isNetworkUnavailable {
            Text("app.error.networkUnavailable.description")
        } else {
            Text("app.error.unexpected.description")
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
            await appEnvironmentModel.initialize(reset: true)
        })
    }
}
