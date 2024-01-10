import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct SplashScreenProvider<Content: View>: View {
    @Environment(AppEnvironmentModel.self) private var appDataEnvironmentModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            content()
            if appDataEnvironmentModel.splashScreenState != .finished {
                SplashScreen()
            }
        }
    }
}

struct AppContentProvider<Content: View>: View {
    @Environment(AppEnvironmentModel.self) private var appDataEnvironmentModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        switch appDataEnvironmentModel.state {
        case .operational:
            content()
        case .networkUnavailable:
            AppNetworkUnavailable()
        case .unexpectedError:
            EmptyView()
        case .tooOldAppVersion:
            EmptyView()
        case .uninitialized:
            EmptyView()
        }
    }
}
