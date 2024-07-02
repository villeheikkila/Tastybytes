import SwiftUI

struct IdiomSelector: View {
    var body: some View {
        #if !os(watchOS)
            OnboardingStateObserver {
                NotificationObserver {
                        TabsView()
                }
            }
        #else
            WatchView()
        #endif
    }
}
