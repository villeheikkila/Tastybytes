import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct SplashScreenProvider<Content: View>: View {
    @State private var splashScreenEnvironmentModel = SplashScreenEnvironmentModel()
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            content()
            if splashScreenEnvironmentModel.state != .finished {
                SplashScreen()
            }
        }.environment(splashScreenEnvironmentModel)
    }
}
