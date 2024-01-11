import EnvironmentModels
import SwiftUI

struct AppStateObserver<Content: View>: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        switch appEnvironmentModel.state {
        case .operational:
            content()
        case .networkUnavailable:
            AppNetworkUnavailableState()
        case .unexpectedError:
            AppUnexpectedErrorState()
        case .tooOldAppVersion:
            AppUnsupportedVersionState()
        case .uninitialized:
            EmptyView()
        }
    }
}
