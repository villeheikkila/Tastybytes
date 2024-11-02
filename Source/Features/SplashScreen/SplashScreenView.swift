import SwiftUI

struct SplashScreenView: View {
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
                    .frame(width: 120, height: 120)
                    .scaleEffect(size)
                    .opacity(opacity)
                AppNameView()
                    .foregroundColor(.primary.opacity(0.80))
            }
        }
        .task {
            await animate()
            try? await Task.sleep(for: .seconds(2))
            await dismiss()
        }
        .opacity(startFadeoutAnimation ? 0 : 1)
    }

    private func animate() async {
        withAnimation(.easeIn(duration: 1)) {
            size = 0.9
            opacity = 1.0
        }
    }

    private func dismiss() async {
        withAnimation(.linear(duration: 0.3)) {
            dismissAnimation = true
            startFadeoutAnimation = true
        }
    }
}

#Preview {
    SplashScreenView()
}
