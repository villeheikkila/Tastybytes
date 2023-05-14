import SwiftUI

struct NotificationTab: View {
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @Binding var resetNavigationOnTab: Tab?

  var body: some View {
    RouterWrapper { router in
      NotificationScreen()
        .task {
          await splashScreenManager.dismiss()
        }
        .onChange(of: $resetNavigationOnTab.wrappedValue) { tab in
          if tab == .notifications {
            if router.path.isEmpty {
              notificationManager.filter = nil
            } else {
              router.reset()
            }
            resetNavigationOnTab = nil
          }
        }
    }
  }
}
