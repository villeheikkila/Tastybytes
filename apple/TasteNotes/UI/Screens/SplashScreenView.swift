import SwiftUI

struct SplashScreenView: View {
  @EnvironmentObject private var splashScreenManager: SplashScreenManager

  @State private var firstAnimation = false
  @State private var secondAnimation = false
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
    }.onReceive(
      Timer
        .publish(every: 0.5, on: .current, in: .common)
        .autoconnect()
    ) { _ in
      updateAnimation()
    }.opacity(startFadeoutAnimation ? 0 : 1)
  }

  private func updateAnimation() {
    switch splashScreenManager.state {
    case .showing:
      withAnimation(.easeIn(duration: 1.2)) {
        self.size = 0.9
        self.opacity = 1.00
      }
    case .dismissing:
      if secondAnimation == false {
        withAnimation(.linear) {
          self.secondAnimation = true
          startFadeoutAnimation = true
        }
      }
    case .finished:
      break
    }
  }
}

struct LaunchScreenView_Previews: PreviewProvider {
  static var previews: some View {
    SplashScreenView()
      .environmentObject(SplashScreenManager())
  }
}

struct LogoShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let width = rect.size.width
    let height = rect.size.height
    path.move(to: CGPoint(x: 0.63678 * width, y: 0.53375 * height))
    path.addLine(to: CGPoint(x: 0.65418 * width, y: 0.51635 * height))
    path.addCurve(
      to: CGPoint(x: 0.71425 * width, y: 0.48824 * height),
      control1: CGPoint(x: 0.66998 * width, y: 0.50055 * height),
      control2: CGPoint(x: 0.69102 * width, y: 0.49093 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.8047 * width, y: 0.44487 * height),
      control1: CGPoint(x: 0.74771 * width, y: 0.48435 * height),
      control2: CGPoint(x: 0.77962 * width, y: 0.46995 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.79773 * width, y: 0.21373 * height),
      control1: CGPoint(x: 0.86661 * width, y: 0.38297 * height),
      control2: CGPoint(x: 0.86349 * width, y: 0.27948 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.56659 * width, y: 0.20676 * height),
      control1: CGPoint(x: 0.73198 * width, y: 0.14798 * height),
      control2: CGPoint(x: 0.62849 * width, y: 0.14486 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.52322 * width, y: 0.29721 * height),
      control1: CGPoint(x: 0.54151 * width, y: 0.23184 * height),
      control2: CGPoint(x: 0.52711 * width, y: 0.26375 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.49511 * width, y: 0.35728 * height),
      control1: CGPoint(x: 0.52053 * width, y: 0.32044 * height),
      control2: CGPoint(x: 0.51091 * width, y: 0.34148 * height)
    )
    path.addLine(to: CGPoint(x: 0.47771 * width, y: 0.37469 * height))
    path.addCurve(
      to: CGPoint(x: 0.42996 * width, y: 0.40076 * height),
      control1: CGPoint(x: 0.4648 * width, y: 0.3876 * height),
      control2: CGPoint(x: 0.44837 * width, y: 0.39657 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.2891 * width, y: 0.47768 * height),
      control1: CGPoint(x: 0.37566 * width, y: 0.41312 * height),
      control2: CGPoint(x: 0.32719 * width, y: 0.43959 * height)
    )
    path.addLine(to: CGPoint(x: 0.02459 * width, y: 0.74218 * height))
    path.addCurve(
      to: CGPoint(x: 0.02938 * width, y: 0.8166 * height),
      control1: CGPoint(x: 0.00537 * width, y: 0.76141 * height),
      control2: CGPoint(x: 0.00751 * width, y: 0.79473 * height)
    )
    path.addLine(to: CGPoint(x: 0.19486 * width, y: 0.98208 * height))
    path.addCurve(
      to: CGPoint(x: 0.26928 * width, y: 0.98687 * height),
      control1: CGPoint(x: 0.21673 * width, y: 1.00395 * height),
      control2: CGPoint(x: 0.25005 * width, y: 1.0061 * height)
    )
    path.addLine(to: CGPoint(x: 0.53378 * width, y: 0.72237 * height))
    path.addCurve(
      to: CGPoint(x: 0.61071 * width, y: 0.5815 * height),
      control1: CGPoint(x: 0.57188 * width, y: 0.68427 * height),
      control2: CGPoint(x: 0.59834 * width, y: 0.6358 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.63678 * width, y: 0.53375 * height),
      control1: CGPoint(x: 0.61489 * width, y: 0.56309 * height),
      control2: CGPoint(x: 0.62387 * width, y: 0.54666 * height)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.48088 * width, y: 0.77527 * height))
    path.addLine(to: CGPoint(x: 0.53378 * width, y: 0.72237 * height))
    path.addCurve(
      to: CGPoint(x: 0.53383 * width, y: 0.72232 * height),
      control1: CGPoint(x: 0.5338 * width, y: 0.72235 * height),
      control2: CGPoint(x: 0.53381 * width, y: 0.72234 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.60144 * width, y: 0.60702 * height),
      control1: CGPoint(x: 0.55152 * width, y: 0.70459 * height),
      control2: CGPoint(x: 0.59843 * width, y: 0.6341 * height)
    )
    path.addLine(to: CGPoint(x: 0.40274 * width, y: 0.40833 * height))
    path.addCurve(
      to: CGPoint(x: 0.2891 * width, y: 0.47768 * height),
      control1: CGPoint(x: 0.35945 * width, y: 0.42251 * height),
      control2: CGPoint(x: 0.3207 * width, y: 0.44608 * height)
    )
    path.addLine(to: CGPoint(x: 0.02459 * width, y: 0.74218 * height))
    path.addCurve(
      to: CGPoint(x: 0.02938 * width, y: 0.8166 * height),
      control1: CGPoint(x: 0.00395 * width, y: 0.76261 * height),
      control2: CGPoint(x: 0.00944 * width, y: 0.79746 * height)
    )
    path.addLine(to: CGPoint(x: 0.07666 * width, y: 0.86388 * height))
    path.addLine(to: CGPoint(x: 0.19486 * width, y: 0.98208 * height))
    path.addCurve(
      to: CGPoint(x: 0.22295 * width, y: 0.99828 * height),
      control1: CGPoint(x: 0.20306 * width, y: 0.99028 * height),
      control2: CGPoint(x: 0.21288 * width, y: 0.99571 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.26928 * width, y: 0.98687 * height),
      control1: CGPoint(x: 0.23912 * width, y: 1.00252 * height),
      control2: CGPoint(x: 0.25732 * width, y: 0.99899 * height)
    )
    path.closeSubpath()
    path
      .addEllipse(in: CGRect(x: 0.61037 * width, y: 0.32127 * height, width: 0.12848 * width, height: 0.12848 * height))
    path.move(to: CGPoint(x: 0.857 * width, y: 0.27555 * height))
    path.addLine(to: CGPoint(x: 0.73591 * width, y: 0.15447 * height))
    path.addLine(to: CGPoint(x: 0.8517 * width, y: 0.03868 * height))
    path.addCurve(
      to: CGPoint(x: 0.92775 * width, y: 0.03868 * height),
      control1: CGPoint(x: 0.8727 * width, y: 0.01768 * height),
      control2: CGPoint(x: 0.90675 * width, y: 0.01768 * height)
    )
    path.addLine(to: CGPoint(x: 0.97278 * width, y: 0.08372 * height))
    path.addCurve(
      to: CGPoint(x: 0.97278 * width, y: 0.15977 * height),
      control1: CGPoint(x: 0.99378 * width, y: 0.10472 * height),
      control2: CGPoint(x: 0.99378 * width, y: 0.13877 * height)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.46735 * width, y: 0.5361 * height))
    path.addLine(to: CGPoint(x: 0.42604 * width, y: 0.4948 * height))
    path.addCurve(
      to: CGPoint(x: 0.40514 * width, y: 0.48741 * height),
      control1: CGPoint(x: 0.42033 * width, y: 0.48908 * height),
      control2: CGPoint(x: 0.4126 * width, y: 0.48663 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.38797 * width, y: 0.4949 * height),
      control1: CGPoint(x: 0.3989 * width, y: 0.48765 * height),
      control2: CGPoint(x: 0.39273 * width, y: 0.49013 * height)
    )
    path.addLine(to: CGPoint(x: 0.33581 * width, y: 0.54705 * height))
    path.addCurve(
      to: CGPoint(x: 0.33581 * width, y: 0.58347 * height),
      control1: CGPoint(x: 0.32576 * width, y: 0.55711 * height),
      control2: CGPoint(x: 0.32576 * width, y: 0.57341 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.37222 * width, y: 0.58347 * height),
      control1: CGPoint(x: 0.34586 * width, y: 0.59352 * height),
      control2: CGPoint(x: 0.36217 * width, y: 0.59352 * height)
    )
    path.addLine(to: CGPoint(x: 0.40706 * width, y: 0.54863 * height))
    path.addLine(to: CGPoint(x: 0.43094 * width, y: 0.57251 * height))
    path.addCurve(
      to: CGPoint(x: 0.46735 * width, y: 0.57251 * height),
      control1: CGPoint(x: 0.44099 * width, y: 0.58257 * height),
      control2: CGPoint(x: 0.4573 * width, y: 0.58257 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.46735 * width, y: 0.5361 * height),
      control1: CGPoint(x: 0.47741 * width, y: 0.56246 * height),
      control2: CGPoint(x: 0.47741 * width, y: 0.54616 * height)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.28261 * width, y: 0.76032 * height))
    path.addCurve(
      to: CGPoint(x: 0.28261 * width, y: 0.72391 * height),
      control1: CGPoint(x: 0.27255 * width, y: 0.75027 * height),
      control2: CGPoint(x: 0.27255 * width, y: 0.73397 * height)
    )
    path.addLine(to: CGPoint(x: 0.33476 * width, y: 0.67175 * height))
    path.addCurve(
      to: CGPoint(x: 0.37118 * width, y: 0.67175 * height),
      control1: CGPoint(x: 0.34482 * width, y: 0.6617 * height),
      control2: CGPoint(x: 0.36112 * width, y: 0.6617 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.37118 * width, y: 0.70817 * height),
      control1: CGPoint(x: 0.38123 * width, y: 0.68181 * height),
      control2: CGPoint(x: 0.38123 * width, y: 0.69811 * height)
    )
    path.addLine(to: CGPoint(x: 0.31902 * width, y: 0.76032 * height))
    path.addCurve(
      to: CGPoint(x: 0.28261 * width, y: 0.76032 * height),
      control1: CGPoint(x: 0.30896 * width, y: 0.77038 * height),
      control2: CGPoint(x: 0.29266 * width, y: 0.77038 * height)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.17146 * width, y: 0.87147 * height))
    path.addCurve(
      to: CGPoint(x: 0.17146 * width, y: 0.83506 * height),
      control1: CGPoint(x: 0.1614 * width, y: 0.86142 * height),
      control2: CGPoint(x: 0.1614 * width, y: 0.84511 * height)
    )
    path.addLine(to: CGPoint(x: 0.22362 * width, y: 0.7829 * height))
    path.addCurve(
      to: CGPoint(x: 0.26003 * width, y: 0.7829 * height),
      control1: CGPoint(x: 0.23367 * width, y: 0.77285 * height),
      control2: CGPoint(x: 0.24997 * width, y: 0.77285 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.26003 * width, y: 0.81931 * height),
      control1: CGPoint(x: 0.27008 * width, y: 0.79296 * height),
      control2: CGPoint(x: 0.27008 * width, y: 0.80926 * height)
    )
    path.addLine(to: CGPoint(x: 0.20787 * width, y: 0.87147 * height))
    path.addCurve(
      to: CGPoint(x: 0.17146 * width, y: 0.87147 * height),
      control1: CGPoint(x: 0.19782 * width, y: 0.88153 * height),
      control2: CGPoint(x: 0.18151 * width, y: 0.88153 * height)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.10963 * width, y: 0.80965 * height))
    path.addCurve(
      to: CGPoint(x: 0.10963 * width, y: 0.77323 * height),
      control1: CGPoint(x: 0.09958 * width, y: 0.79959 * height),
      control2: CGPoint(x: 0.09958 * width, y: 0.78329 * height)
    )
    path.addLine(to: CGPoint(x: 0.16179 * width, y: 0.72108 * height))
    path.addCurve(
      to: CGPoint(x: 0.1982 * width, y: 0.72108 * height),
      control1: CGPoint(x: 0.17184 * width, y: 0.71102 * height),
      control2: CGPoint(x: 0.18815 * width, y: 0.71102 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.1982 * width, y: 0.75749 * height),
      control1: CGPoint(x: 0.20826 * width, y: 0.73113 * height),
      control2: CGPoint(x: 0.20826 * width, y: 0.74743 * height)
    )
    path.addLine(to: CGPoint(x: 0.14605 * width, y: 0.80965 * height))
    path.addCurve(
      to: CGPoint(x: 0.10963 * width, y: 0.80965 * height),
      control1: CGPoint(x: 0.13599 * width, y: 0.8197 * height),
      control2: CGPoint(x: 0.11969 * width, y: 0.8197 * height)
    )
    path.closeSubpath()
    path
      .addEllipse(in: CGRect(x: 0.26331 * width, y: 0.60325 * height, width: 0.05567 * width, height: 0.05567 * height))
    path.move(to: CGPoint(x: 0.79773 * width, y: 0.21373 * height))
    path.addCurve(
      to: CGPoint(x: 0.77163 * width, y: 0.19214 * height),
      control1: CGPoint(x: 0.78956 * width, y: 0.20556 * height),
      control2: CGPoint(x: 0.78081 * width, y: 0.19837 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.73758 * width, y: 0.35135 * height),
      control1: CGPoint(x: 0.79778 * width, y: 0.23753 * height),
      control2: CGPoint(x: 0.78499 * width, y: 0.30394 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.66284 * width, y: 0.39466 * height),
      control1: CGPoint(x: 0.71545 * width, y: 0.37347 * height),
      control2: CGPoint(x: 0.68919 * width, y: 0.38806 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.61328 * width, y: 0.4229 * height),
      control1: CGPoint(x: 0.64456 * width, y: 0.39925 * height),
      control2: CGPoint(x: 0.62722 * width, y: 0.40896 * height)
    )
    path.addLine(to: CGPoint(x: 0.59793 * width, y: 0.43825 * height))
    path.addCurve(
      to: CGPoint(x: 0.5726 * width, y: 0.47804 * height),
      control1: CGPoint(x: 0.58654 * width, y: 0.44964 * height),
      control2: CGPoint(x: 0.57783 * width, y: 0.46333 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.49787 * width, y: 0.59544 * height),
      control1: CGPoint(x: 0.55719 * width, y: 0.52144 * height),
      control2: CGPoint(x: 0.53147 * width, y: 0.56184 * height)
    )
    path.addLine(to: CGPoint(x: 0.26453 * width, y: 0.82879 * height))
    path.addCurve(
      to: CGPoint(x: 0.20739 * width, y: 0.83308 * height),
      control1: CGPoint(x: 0.24756 * width, y: 0.84575 * height),
      control2: CGPoint(x: 0.22198 * width, y: 0.84767 * height)
    )
    path.addLine(to: CGPoint(x: 0.09697 * width, y: 0.72266 * height))
    path.addCurve(
      to: CGPoint(x: 0.10126 * width, y: 0.66552 * height),
      control1: CGPoint(x: 0.08238 * width, y: 0.70807 * height),
      control2: CGPoint(x: 0.0843 * width, y: 0.68248 * height)
    )
    path.addLine(to: CGPoint(x: 0.0246 * width, y: 0.74218 * height))
    path.addCurve(
      to: CGPoint(x: 0.02938 * width, y: 0.8166 * height),
      control1: CGPoint(x: 0.00537 * width, y: 0.76141 * height),
      control2: CGPoint(x: 0.00751 * width, y: 0.79473 * height)
    )
    path.addLine(to: CGPoint(x: 0.19486 * width, y: 0.98208 * height))
    path.addCurve(
      to: CGPoint(x: 0.26928 * width, y: 0.98687 * height),
      control1: CGPoint(x: 0.21673 * width, y: 1.00395 * height),
      control2: CGPoint(x: 0.25005 * width, y: 1.0061 * height)
    )
    path.addLine(to: CGPoint(x: 0.53378 * width, y: 0.72237 * height))
    path.addCurve(
      to: CGPoint(x: 0.61071 * width, y: 0.5815 * height),
      control1: CGPoint(x: 0.57188 * width, y: 0.68427 * height),
      control2: CGPoint(x: 0.59834 * width, y: 0.6358 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.63678 * width, y: 0.53375 * height),
      control1: CGPoint(x: 0.61489 * width, y: 0.56309 * height),
      control2: CGPoint(x: 0.62387 * width, y: 0.54666 * height)
    )
    path.addLine(to: CGPoint(x: 0.65418 * width, y: 0.51635 * height))
    path.addCurve(
      to: CGPoint(x: 0.71425 * width, y: 0.48824 * height),
      control1: CGPoint(x: 0.66998 * width, y: 0.50055 * height),
      control2: CGPoint(x: 0.69102 * width, y: 0.49094 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.8047 * width, y: 0.44487 * height),
      control1: CGPoint(x: 0.74771 * width, y: 0.48435 * height),
      control2: CGPoint(x: 0.77962 * width, y: 0.46996 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.79773 * width, y: 0.21373 * height),
      control1: CGPoint(x: 0.86661 * width, y: 0.38297 * height),
      control2: CGPoint(x: 0.86349 * width, y: 0.27948 * height)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.72004 * width, y: 0.43094 * height))
    path.addCurve(
      to: CGPoint(x: 0.73201 * width, y: 0.35665 * height),
      control1: CGPoint(x: 0.74014 * width, y: 0.41083 * height),
      control2: CGPoint(x: 0.74412 * width, y: 0.38073 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.66285 * width, y: 0.39466 * height),
      control1: CGPoint(x: 0.71111 * width, y: 0.37581 * height),
      control2: CGPoint(x: 0.68701 * width, y: 0.3886 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.61896 * width, y: 0.41762 * height),
      control1: CGPoint(x: 0.64696 * width, y: 0.39864 * height),
      control2: CGPoint(x: 0.63181 * width, y: 0.4065 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.62919 * width, y: 0.43094 * height),
      control1: CGPoint(x: 0.62171 * width, y: 0.42238 * height),
      control2: CGPoint(x: 0.62511 * width, y: 0.42686 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.72004 * width, y: 0.43094 * height),
      control1: CGPoint(x: 0.65427 * width, y: 0.45603 * height),
      control2: CGPoint(x: 0.69495 * width, y: 0.45603 * height)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.26928 * width, y: 0.98687 * height))
    path.addLine(to: CGPoint(x: 0.53378 * width, y: 0.72237 * height))
    path.addCurve(
      to: CGPoint(x: 0.60314 * width, y: 0.60872 * height),
      control1: CGPoint(x: 0.56538 * width, y: 0.69077 * height),
      control2: CGPoint(x: 0.58895 * width, y: 0.65201 * height)
    )
    path.addLine(to: CGPoint(x: 0.5392 * width, y: 0.54478 * height))
    path.addCurve(
      to: CGPoint(x: 0.49787 * width, y: 0.59544 * height),
      control1: CGPoint(x: 0.52726 * width, y: 0.56287 * height),
      control2: CGPoint(x: 0.51343 * width, y: 0.57989 * height)
    )
    path.addLine(to: CGPoint(x: 0.26453 * width, y: 0.82879 * height))
    path.addCurve(
      to: CGPoint(x: 0.20739 * width, y: 0.83308 * height),
      control1: CGPoint(x: 0.24756 * width, y: 0.84575 * height),
      control2: CGPoint(x: 0.22198 * width, y: 0.84767 * height)
    )
    path.addLine(to: CGPoint(x: 0.09697 * width, y: 0.72266 * height))
    path.addCurve(
      to: CGPoint(x: 0.10126 * width, y: 0.66552 * height),
      control1: CGPoint(x: 0.08238 * width, y: 0.70807 * height),
      control2: CGPoint(x: 0.0843 * width, y: 0.68248 * height)
    )
    path.addLine(to: CGPoint(x: 0.02273 * width, y: 0.74418 * height))
    path.addCurve(
      to: CGPoint(x: 0.02938 * width, y: 0.8166 * height),
      control1: CGPoint(x: 0.00415 * width, y: 0.76493 * height),
      control2: CGPoint(x: 0.01029 * width, y: 0.79827 * height)
    )
    path.addLine(to: CGPoint(x: 0.19486 * width, y: 0.98208 * height))
    path.addCurve(
      to: CGPoint(x: 0.24305 * width, y: 0.99957 * height),
      control1: CGPoint(x: 0.20853 * width, y: 0.99575 * height),
      control2: CGPoint(x: 0.22667 * width, y: 1.00172 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.26928 * width, y: 0.98687 * height),
      control1: CGPoint(x: 0.25292 * width, y: 0.99829 * height),
      control2: CGPoint(x: 0.26219 * width, y: 0.99398 * height)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.12859 * width, y: 0.75428 * height))
    path.addLine(to: CGPoint(x: 0.10963 * width, y: 0.77323 * height))
    path.addCurve(
      to: CGPoint(x: 0.10963 * width, y: 0.80965 * height),
      control1: CGPoint(x: 0.09958 * width, y: 0.78329 * height),
      control2: CGPoint(x: 0.09958 * width, y: 0.79959 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.14604 * width, y: 0.80965 * height),
      control1: CGPoint(x: 0.11969 * width, y: 0.8197 * height),
      control2: CGPoint(x: 0.13599 * width, y: 0.8197 * height)
    )
    path.addLine(to: CGPoint(x: 0.165 * width, y: 0.79069 * height))
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.23678 * width, y: 0.84256 * height))
    path.addCurve(
      to: CGPoint(x: 0.20739 * width, y: 0.83308 * height),
      control1: CGPoint(x: 0.22585 * width, y: 0.84383 * height),
      control2: CGPoint(x: 0.21509 * width, y: 0.84078 * height)
    )
    path.addLine(to: CGPoint(x: 0.19041 * width, y: 0.8161 * height))
    path.addLine(to: CGPoint(x: 0.17146 * width, y: 0.83506 * height))
    path.addCurve(
      to: CGPoint(x: 0.17146 * width, y: 0.87147 * height),
      control1: CGPoint(x: 0.1614 * width, y: 0.84511 * height),
      control2: CGPoint(x: 0.1614 * width, y: 0.86141 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.20787 * width, y: 0.87147 * height),
      control1: CGPoint(x: 0.18151 * width, y: 0.88152 * height),
      control2: CGPoint(x: 0.19782 * width, y: 0.88152 * height)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.33218 * width, y: 0.83964 * height))
    path.addCurve(
      to: CGPoint(x: 0.32367 * width, y: 0.8361 * height),
      control1: CGPoint(x: 0.32909 * width, y: 0.83964 * height),
      control2: CGPoint(x: 0.32601 * width, y: 0.83846 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.3237 * width, y: 0.81912 * height),
      control1: CGPoint(x: 0.31899 * width, y: 0.8314 * height),
      control2: CGPoint(x: 0.319 * width, y: 0.8238 * height)
    )
    path.addLine(to: CGPoint(x: 0.40737 * width, y: 0.73579 * height))
    path.addCurve(
      to: CGPoint(x: 0.42435 * width, y: 0.73583 * height),
      control1: CGPoint(x: 0.41207 * width, y: 0.73111 * height),
      control2: CGPoint(x: 0.41967 * width, y: 0.73113 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.42431 * width, y: 0.75281 * height),
      control1: CGPoint(x: 0.42903 * width, y: 0.74053 * height),
      control2: CGPoint(x: 0.42901 * width, y: 0.74813 * height)
    )
    path.addLine(to: CGPoint(x: 0.34065 * width, y: 0.83614 * height))
    path.addCurve(
      to: CGPoint(x: 0.33218 * width, y: 0.83964 * height),
      control1: CGPoint(x: 0.33831 * width, y: 0.83847 * height),
      control2: CGPoint(x: 0.33524 * width, y: 0.83964 * height)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.269 * width, y: 0.90315 * height))
    path.addCurve(
      to: CGPoint(x: 0.26059 * width, y: 0.8997 * height),
      control1: CGPoint(x: 0.26596 * width, y: 0.90315 * height),
      control2: CGPoint(x: 0.26292 * width, y: 0.902 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.26044 * width, y: 0.88272 * height),
      control1: CGPoint(x: 0.25586 * width, y: 0.89505 * height),
      control2: CGPoint(x: 0.25579 * width, y: 0.88745 * height)
    )
    path.addLine(to: CGPoint(x: 0.28372 * width, y: 0.85905 * height))
    path.addCurve(
      to: CGPoint(x: 0.3007 * width, y: 0.85891 * height),
      control1: CGPoint(x: 0.28837 * width, y: 0.85432 * height),
      control2: CGPoint(x: 0.29597 * width, y: 0.85425 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.30084 * width, y: 0.87588 * height),
      control1: CGPoint(x: 0.30543 * width, y: 0.86355 * height),
      control2: CGPoint(x: 0.30549 * width, y: 0.87116 * height)
    )
    path.addLine(to: CGPoint(x: 0.27757 * width, y: 0.89956 * height))
    path.addCurve(
      to: CGPoint(x: 0.269 * width, y: 0.90315 * height),
      control1: CGPoint(x: 0.27522 * width, y: 0.90195 * height),
      control2: CGPoint(x: 0.27211 * width, y: 0.90315 * height)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.24048 * width, y: 0.93167 * height))
    path.addCurve(
      to: CGPoint(x: 0.23199 * width, y: 0.92815 * height),
      control1: CGPoint(x: 0.23741 * width, y: 0.93167 * height),
      control2: CGPoint(x: 0.23434 * width, y: 0.9305 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.23199 * width, y: 0.91117 * height),
      control1: CGPoint(x: 0.2273 * width, y: 0.92346 * height),
      control2: CGPoint(x: 0.2273 * width, y: 0.91586 * height)
    )
    path.addLine(to: CGPoint(x: 0.23879 * width, y: 0.90437 * height))
    path.addCurve(
      to: CGPoint(x: 0.25577 * width, y: 0.90437 * height),
      control1: CGPoint(x: 0.24348 * width, y: 0.89968 * height),
      control2: CGPoint(x: 0.25108 * width, y: 0.89969 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.25577 * width, y: 0.92135 * height),
      control1: CGPoint(x: 0.26046 * width, y: 0.90906 * height),
      control2: CGPoint(x: 0.26046 * width, y: 0.91667 * height)
    )
    path.addLine(to: CGPoint(x: 0.24897 * width, y: 0.92815 * height))
    path.addCurve(
      to: CGPoint(x: 0.24048 * width, y: 0.93167 * height),
      control1: CGPoint(x: 0.24663 * width, y: 0.9305 * height),
      control2: CGPoint(x: 0.24356 * width, y: 0.93167 * height)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.66024 * width, y: 0.23896 * height))
    path.addCurve(
      to: CGPoint(x: 0.64076 * width, y: 0.22346 * height),
      control1: CGPoint(x: 0.65113 * width, y: 0.23896 * height),
      control2: CGPoint(x: 0.6429 * width, y: 0.23271 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.65575 * width, y: 0.19945 * height),
      control1: CGPoint(x: 0.63827 * width, y: 0.21269 * height),
      control2: CGPoint(x: 0.64498 * width, y: 0.20194 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.66938 * width, y: 0.19696 * height),
      control1: CGPoint(x: 0.66021 * width, y: 0.19842 * height),
      control2: CGPoint(x: 0.66479 * width, y: 0.19758 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.69189 * width, y: 0.21413 * height),
      control1: CGPoint(x: 0.68034 * width, y: 0.19549 * height),
      control2: CGPoint(x: 0.69041 * width, y: 0.20317 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.67472 * width, y: 0.23663 * height),
      control1: CGPoint(x: 0.69336 * width, y: 0.22508 * height),
      control2: CGPoint(x: 0.68568 * width, y: 0.23516 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.66476 * width, y: 0.23845 * height),
      control1: CGPoint(x: 0.67137 * width, y: 0.23708 * height),
      control2: CGPoint(x: 0.66802 * width, y: 0.23769 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.66024 * width, y: 0.23896 * height),
      control1: CGPoint(x: 0.66325 * width, y: 0.2388 * height),
      control2: CGPoint(x: 0.66173 * width, y: 0.23896 * height)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.58182 * width, y: 0.3174 * height))
    path.addCurve(
      to: CGPoint(x: 0.57626 * width, y: 0.31661 * height),
      control1: CGPoint(x: 0.57998 * width, y: 0.3174 * height),
      control2: CGPoint(x: 0.57811 * width, y: 0.31715 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.56259 * width, y: 0.29183 * height),
      control1: CGPoint(x: 0.56564 * width, y: 0.31355 * height),
      control2: CGPoint(x: 0.55952 * width, y: 0.30245 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.60046 * width, y: 0.2281 * height),
      control1: CGPoint(x: 0.57001 * width, y: 0.26615 * height),
      control2: CGPoint(x: 0.5831 * width, y: 0.24411 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.62874 * width, y: 0.22924 * height),
      control1: CGPoint(x: 0.60858 * width, y: 0.22061 * height),
      control2: CGPoint(x: 0.62124 * width, y: 0.22112 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.62759 * width, y: 0.25752 * height),
      control1: CGPoint(x: 0.63623 * width, y: 0.23737 * height),
      control2: CGPoint(x: 0.63572 * width, y: 0.25003 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.60104 * width, y: 0.30294 * height),
      control1: CGPoint(x: 0.61561 * width, y: 0.26857 * height),
      control2: CGPoint(x: 0.60643 * width, y: 0.28428 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.58182 * width, y: 0.3174 * height),
      control1: CGPoint(x: 0.59851 * width, y: 0.3117 * height),
      control2: CGPoint(x: 0.59051 * width, y: 0.3174 * height)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.83246 * width, y: 0.27872 * height))
    path.addLine(to: CGPoint(x: 0.73602 * width, y: 0.18228 * height))
    path.addCurve(
      to: CGPoint(x: 0.73602 * width, y: 0.12825 * height),
      control1: CGPoint(x: 0.7211 * width, y: 0.16736 * height),
      control2: CGPoint(x: 0.7211 * width, y: 0.14317 * height)
    )
    path.addLine(to: CGPoint(x: 0.78978 * width, y: 0.07448 * height))
    path.addCurve(
      to: CGPoint(x: 0.84381 * width, y: 0.07448 * height),
      control1: CGPoint(x: 0.8047 * width, y: 0.05956 * height),
      control2: CGPoint(x: 0.82889 * width, y: 0.05956 * height)
    )
    path.addLine(to: CGPoint(x: 0.94026 * width, y: 0.17092 * height))
    path.addCurve(
      to: CGPoint(x: 0.94026 * width, y: 0.22495 * height),
      control1: CGPoint(x: 0.95518 * width, y: 0.18584 * height),
      control2: CGPoint(x: 0.95518 * width, y: 0.21003 * height)
    )
    path.addLine(to: CGPoint(x: 0.88649 * width, y: 0.27872 * height))
    path.addCurve(
      to: CGPoint(x: 0.83246 * width, y: 0.27872 * height),
      control1: CGPoint(x: 0.87157 * width, y: 0.29364 * height),
      control2: CGPoint(x: 0.84738 * width, y: 0.29364 * height)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.94025 * width, y: 0.17092 * height))
    path.addLine(to: CGPoint(x: 0.88181 * width, y: 0.11248 * height))
    path.addCurve(
      to: CGPoint(x: 0.88181 * width, y: 0.16652 * height),
      control1: CGPoint(x: 0.89673 * width, y: 0.12741 * height),
      control2: CGPoint(x: 0.89673 * width, y: 0.15159 * height)
    )
    path.addLine(to: CGPoint(x: 0.82805 * width, y: 0.22028 * height))
    path.addCurve(
      to: CGPoint(x: 0.77402 * width, y: 0.22028 * height),
      control1: CGPoint(x: 0.81313 * width, y: 0.2352 * height),
      control2: CGPoint(x: 0.78894 * width, y: 0.2352 * height)
    )
    path.addLine(to: CGPoint(x: 0.83246 * width, y: 0.27872 * height))
    path.addCurve(
      to: CGPoint(x: 0.88649 * width, y: 0.27872 * height),
      control1: CGPoint(x: 0.84738 * width, y: 0.29364 * height),
      control2: CGPoint(x: 0.87157 * width, y: 0.29364 * height)
    )
    path.addLine(to: CGPoint(x: 0.94025 * width, y: 0.22495 * height))
    path.addCurve(
      to: CGPoint(x: 0.94025 * width, y: 0.17092 * height),
      control1: CGPoint(x: 0.95518 * width, y: 0.21003 * height),
      control2: CGPoint(x: 0.95518 * width, y: 0.18584 * height)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.94025 * width, y: 0.19094 * height))
    path.addCurve(
      to: CGPoint(x: 0.9261 * width, y: 0.18508 * height),
      control1: CGPoint(x: 0.93513 * width, y: 0.19094 * height),
      control2: CGPoint(x: 0.93001 * width, y: 0.18898 * height)
    )
    path.addLine(to: CGPoint(x: 0.82966 * width, y: 0.08863 * height))
    path.addCurve(
      to: CGPoint(x: 0.82966 * width, y: 0.06033 * height),
      control1: CGPoint(x: 0.82185 * width, y: 0.08082 * height),
      control2: CGPoint(x: 0.82185 * width, y: 0.06815 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.85796 * width, y: 0.06033 * height),
      control1: CGPoint(x: 0.83748 * width, y: 0.05252 * height),
      control2: CGPoint(x: 0.85015 * width, y: 0.05252 * height)
    )
    path.addLine(to: CGPoint(x: 0.95441 * width, y: 0.15677 * height))
    path.addCurve(
      to: CGPoint(x: 0.95441 * width, y: 0.18508 * height),
      control1: CGPoint(x: 0.96222 * width, y: 0.16459 * height),
      control2: CGPoint(x: 0.96222 * width, y: 0.17726 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.94025 * width, y: 0.19094 * height),
      control1: CGPoint(x: 0.9505 * width, y: 0.18898 * height),
      control2: CGPoint(x: 0.94537 * width, y: 0.19094 * height)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.48791 * width, y: 0.45943 * height))
    path.addCurve(
      to: CGPoint(x: 0.47681 * width, y: 0.45199 * height),
      control1: CGPoint(x: 0.48319 * width, y: 0.45943 * height),
      control2: CGPoint(x: 0.47871 * width, y: 0.45663 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.48334 * width, y: 0.43631 * height),
      control1: CGPoint(x: 0.47428 * width, y: 0.44586 * height),
      control2: CGPoint(x: 0.4772 * width, y: 0.43884 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.55084 * width, y: 0.36521 * height),
      control1: CGPoint(x: 0.53934 * width, y: 0.41325 * height),
      control2: CGPoint(x: 0.55074 * width, y: 0.36569 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.56521 * width, y: 0.35617 * height),
      control1: CGPoint(x: 0.55231 * width, y: 0.35875 * height),
      control2: CGPoint(x: 0.55875 * width, y: 0.3547 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.57426 * width, y: 0.37054 * height),
      control1: CGPoint(x: 0.57168 * width, y: 0.35763 * height),
      control2: CGPoint(x: 0.57573 * width, y: 0.36407 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.49248 * width, y: 0.45852 * height),
      control1: CGPoint(x: 0.57371 * width, y: 0.37298 * height),
      control2: CGPoint(x: 0.55987 * width, y: 0.43077 * height)
    )
    path.addCurve(
      to: CGPoint(x: 0.48791 * width, y: 0.45943 * height),
      control1: CGPoint(x: 0.49098 * width, y: 0.45913 * height),
      control2: CGPoint(x: 0.48944 * width, y: 0.45943 * height)
    )
    path.closeSubpath()
    path.move(to: CGPoint(x: 0.37257 * width, y: 0.0049 * height))
    path.addLine(to: CGPoint(x: 0.389 * width, y: 0.05112 * height))
    path.addCurve(
      to: CGPoint(x: 0.39286 * width, y: 0.05546 * height),
      control1: CGPoint(x: 0.38971 * width, y: 0.0531 * height),
      control2: CGPoint(x: 0.3911 * width, y: 0.05467 * height)
    )
    path.addLine(to: CGPoint(x: 0.43393 * width, y: 0.07397 * height))
    path.addCurve(
      to: CGPoint(x: 0.43393 * width, y: 0.08844 * height),
      control1: CGPoint(x: 0.43973 * width, y: 0.07658 * height),
      control2: CGPoint(x: 0.43973 * width, y: 0.08582 * height)
    )
    path.addLine(to: CGPoint(x: 0.39286 * width, y: 0.10694 * height))
    path.addCurve(
      to: CGPoint(x: 0.389 * width, y: 0.11128 * height),
      control1: CGPoint(x: 0.3911 * width, y: 0.10774 * height),
      control2: CGPoint(x: 0.38971 * width, y: 0.1093 * height)
    )
    path.addLine(to: CGPoint(x: 0.37257 * width, y: 0.15751 * height))
    path.addCurve(
      to: CGPoint(x: 0.35971 * width, y: 0.15751 * height),
      control1: CGPoint(x: 0.37024 * width, y: 0.16404 * height),
      control2: CGPoint(x: 0.36203 * width, y: 0.16404 * height)
    )
    path.addLine(to: CGPoint(x: 0.34327 * width, y: 0.11128 * height))
    path.addCurve(
      to: CGPoint(x: 0.33941 * width, y: 0.10694 * height),
      control1: CGPoint(x: 0.34256 * width, y: 0.1093 * height),
      control2: CGPoint(x: 0.34117 * width, y: 0.10773 * height)
    )
    path.addLine(to: CGPoint(x: 0.29834 * width, y: 0.08844 * height))
    path.addCurve(
      to: CGPoint(x: 0.29834 * width, y: 0.07397 * height),
      control1: CGPoint(x: 0.29254 * width, y: 0.08583 * height),
      control2: CGPoint(x: 0.29254 * width, y: 0.07658 * height)
    )
    path.addLine(to: CGPoint(x: 0.33941 * width, y: 0.05546 * height))
    path.addCurve(
      to: CGPoint(x: 0.34327 * width, y: 0.05112 * height),
      control1: CGPoint(x: 0.34117 * width, y: 0.05467 * height),
      control2: CGPoint(x: 0.34256 * width, y: 0.0531 * height)
    )
    path.addLine(to: CGPoint(x: 0.35971 * width, y: 0.0049 * height))
    path.addCurve(
      to: CGPoint(x: 0.37257 * width, y: 0.0049 * height),
      control1: CGPoint(x: 0.36203 * width, y: -0.00163 * height),
      control2: CGPoint(x: 0.37024 * width, y: -0.00163 * height)
    )
    path.closeSubpath()
    path
      .addEllipse(in: CGRect(x: 0.21701 * width, y: 0.26688 * height, width: 0.07179 * width, height: 0.07179 * height))
    path
      .addEllipse(in: CGRect(x: 0.58976 * width, y: 0.02532 * height, width: 0.03097 * width, height: 0.03097 * height))
    path.move(to: CGPoint(x: 0.93015 * width, y: 0.4629 * height))
    path.addLine(to: CGPoint(x: 0.94234 * width, y: 0.49719 * height))
    path.addCurve(
      to: CGPoint(x: 0.9452 * width, y: 0.50041 * height),
      control1: CGPoint(x: 0.94287 * width, y: 0.49866 * height),
      control2: CGPoint(x: 0.9439 * width, y: 0.49982 * height)
    )
    path.addLine(to: CGPoint(x: 0.97567 * width, y: 0.51414 * height))
    path.addCurve(
      to: CGPoint(x: 0.97567 * width, y: 0.52487 * height),
      control1: CGPoint(x: 0.97997 * width, y: 0.51608 * height),
      control2: CGPoint(x: 0.97997 * width, y: 0.52293 * height)
    )
    path.addLine(to: CGPoint(x: 0.9452 * width, y: 0.5386 * height))
    path.addCurve(
      to: CGPoint(x: 0.94234 * width, y: 0.54182 * height),
      control1: CGPoint(x: 0.9439 * width, y: 0.53919 * height),
      control2: CGPoint(x: 0.94287 * width, y: 0.54035 * height)
    )
    path.addLine(to: CGPoint(x: 0.93015 * width, y: 0.57611 * height))
    path.addCurve(
      to: CGPoint(x: 0.92061 * width, y: 0.57611 * height),
      control1: CGPoint(x: 0.92843 * width, y: 0.58095 * height),
      control2: CGPoint(x: 0.92233 * width, y: 0.58095 * height)
    )
    path.addLine(to: CGPoint(x: 0.90842 * width, y: 0.54182 * height))
    path.addCurve(
      to: CGPoint(x: 0.90556 * width, y: 0.5386 * height),
      control1: CGPoint(x: 0.90789 * width, y: 0.54035 * height),
      control2: CGPoint(x: 0.90686 * width, y: 0.53919 * height)
    )
    path.addLine(to: CGPoint(x: 0.87509 * width, y: 0.52487 * height))
    path.addCurve(
      to: CGPoint(x: 0.87509 * width, y: 0.51414 * height),
      control1: CGPoint(x: 0.87079 * width, y: 0.52293 * height),
      control2: CGPoint(x: 0.87079 * width, y: 0.51608 * height)
    )
    path.addLine(to: CGPoint(x: 0.90556 * width, y: 0.50041 * height))
    path.addCurve(
      to: CGPoint(x: 0.90842 * width, y: 0.49719 * height),
      control1: CGPoint(x: 0.90686 * width, y: 0.49982 * height),
      control2: CGPoint(x: 0.90789 * width, y: 0.49866 * height)
    )
    path.addLine(to: CGPoint(x: 0.92061 * width, y: 0.4629 * height))
    path.addCurve(
      to: CGPoint(x: 0.93015 * width, y: 0.4629 * height),
      control1: CGPoint(x: 0.92233 * width, y: 0.45806 * height),
      control2: CGPoint(x: 0.92843 * width, y: 0.45806 * height)
    )
    path.closeSubpath()
    return path
  }
}
