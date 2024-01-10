import EnvironmentModels
import SwiftUI

struct AppStateSelector<Content: View>: View {
    @Environment(AppEnvironmentModel.self) private var appDataEnvironmentModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        switch appDataEnvironmentModel.state {
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
