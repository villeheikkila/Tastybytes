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
                Image(systemName: "takeoutbag.and.cup.and.straw")
                    .font(.system(size: 100))
                    .scaleEffect(size)
                    .opacity(opacity)

                Text("TasteNotes")
                    .font(Font.custom("Menlo-Bold", size: 28))
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
