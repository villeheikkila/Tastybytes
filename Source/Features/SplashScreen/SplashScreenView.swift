import Components
import EnvironmentModels
import SwiftUI

struct SplashScreen: View {
    @Environment(AppEnvironmentModel.self) private var appDataEnvironmentModel
    @State private var dismissAnimation = false
    @State private var startFadeoutAnimation = false
    @State private var size = 0.8
    @State private var opacity = 0.5

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            VStack(spacing: 24) {
                AppLogoView()
                    .scaleEffect(size)
                    .opacity(opacity)
                AppNameView()
                    .foregroundColor(.primary.opacity(0.80))
            }
        }
        .onReceive(
            Timer
                .publish(every: 0.5, on: .current, in: .common)
                .autoconnect()
        ) { _ in
            updateAnimation()
        }
        .opacity(startFadeoutAnimation ? 0 : 1)
    }

    @MainActor
    private func updateAnimation() {
        switch appDataEnvironmentModel.splashScreenState {
        case .showing:
            withAnimation(.easeIn(duration: 1)) {
                size = 0.9
                opacity = 1.00
            }
        case .dismissing:
            if dismissAnimation == false {
                withAnimation(.linear) {
                    dismissAnimation = true
                    startFadeoutAnimation = true
                }
            }
        case .finished:
            break
        }
    }
}
