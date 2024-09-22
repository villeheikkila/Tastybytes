import Models
import SwiftUI

struct SplashScreenProvider<Content: View>: View {
    @Environment(AppModel.self) private var appModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            content()
            if appModel.splashScreenState != .finished {
                SplashScreenView()
            }
        }
    }
}
