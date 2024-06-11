import EnvironmentModels
import SwiftUI

@MainActor
struct AppStateObserver<Content: View>: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        switch appEnvironmentModel.state {
        case .operational:
            content()
        case let .error(errors):
            AppErrorStateView(errors: errors)
        case .tooOldAppVersion:
            AppUnsupportedVersionState()
        case .loading:
            EmptyView()
        }
    }
}
