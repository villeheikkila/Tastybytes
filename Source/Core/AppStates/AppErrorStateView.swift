import Components

import SwiftUI

struct AppErrorStateView: View {
    @Environment(AppModel.self) private var appModel
    let error: Error

    private var title: LocalizedStringKey {
        if error.isNetworkUnavailable {
            "app.error.networkUnavailable.title"
        } else {
            "app.error.unexpected.title"
        }
    }

    private var description: Text {
        if error.isNetworkUnavailable {
            Text("app.error.networkUnavailable.description")
        } else {
            Text("app.error.unexpected.description")
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
            await appModel.initialize(cache: true)
        })
    }
}
