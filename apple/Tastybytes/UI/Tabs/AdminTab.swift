import SwiftUI

struct AdminTab: View {
  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @Binding var resetNavigationOnTab: Tab?

  var body: some View {
    RouterWrapper(tab: .admin) { router in
      AdminScreen()
        .task {
          await splashScreenManager.dismiss()
        }
        .onChange(of: $resetNavigationOnTab.wrappedValue) { tab in
          if tab == .admin {
            router.reset()
            resetNavigationOnTab = nil
          }
        }
    }
  }
}
