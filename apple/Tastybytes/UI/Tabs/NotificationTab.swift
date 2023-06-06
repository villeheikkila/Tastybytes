import SwiftUI

struct NotificationTab: View {
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @State private var scrollToTop: Int = 0
  @Binding var resetNavigationOnTab: Tab?

  var body: some View {
    RouterWrapper(tab: .notifications) { router in
      NotificationScreen(scrollToTop: $scrollToTop)
        .task {
          await splashScreenManager.dismiss()
        }
        .onChange(of: $resetNavigationOnTab.wrappedValue) { _, tab in
          if tab == .notifications {
            if router.path.isEmpty {
              notificationManager.filter = nil
              scrollToTop += 1
            } else {
              router.reset()
            }
            resetNavigationOnTab = nil
          }
        }
    }
  }
}
