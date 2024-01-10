import Components
import EnvironmentModels
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
