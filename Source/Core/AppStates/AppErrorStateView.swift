import Components

import SwiftUI

struct AppErrorStateView: View {
    @Environment(AppModel.self) private var appModel
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
            await appModel.initialize(reset: true)
        })
    }
}
