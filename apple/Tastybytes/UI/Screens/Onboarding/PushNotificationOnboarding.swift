import SwiftUI

struct PushNotificationOnboarding: View {
  @Binding var currentTab: OnboardingScreen.Tab

  var body: some View {
    Form {}
      .modifier(OnboardingContinueButtonModifier(title: "Continue", onClick: {
        if let nextTab = currentTab.next {
          withAnimation {
            currentTab = nextTab
          }
        }
      }))
      .onAppear {
        requestPushNotificationPermission()
      }
  }

  func requestPushNotificationPermission() {
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions
    ) { _, _ in }
  }
}

struct PushNotificationOnboarding_Previews: PreviewProvider {
  static var previews: some View {
    PushNotificationOnboarding(currentTab: .constant(OnboardingScreen.Tab.final))
  }
}
