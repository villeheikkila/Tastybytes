import Components
import EnvironmentModels
import SwiftUI

@MainActor
struct SplashScreenProvider<Content: View>: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            content()
            if appEnvironmentModel.splashScreenState != .finished {
                SplashScreen()
            }
        }
    }
}
