import SwiftUI

struct SplashScreen: View {
  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @State private var dismissAnimation = false
  @State private var startFadeoutAnimation = false
  @State private var size = 0.8
  @State private var opacity = 0.5

  var body: some View {
    ZStack {
      Color(.systemBackground)
        .ignoresSafeArea()
      VStack {
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

  private func updateAnimation() {
    switch splashScreenManager.state {
    case .showing:
      withAnimation(.easeIn(duration: 1.2)) {
        self.size = 0.9
        self.opacity = 1.00
      }
    case .dismissing:
      if dismissAnimation == false {
        withAnimation(.linear) {
          self.dismissAnimation = true
          startFadeoutAnimation = true
        }
      }
    case .finished:
      break
    }
  }
}

struct LaunchScreen_Previews: PreviewProvider {
  static var previews: some View {
    SplashScreen()
      .environmentObject(SplashScreenManager())
  }
}
