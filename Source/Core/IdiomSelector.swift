import SwiftUI

struct IdiomSelector: View {
    var body: some View {
        #if !os(watchOS)
            OnboardingStateObserver {
                NotificationObserver {
                    switch UIDevice.current.userInterfaceIdiom {
                    case .mac, .vision:
                        SideBarView()
                    case .phone, .pad:
                        TabsView()
                    default:
                        EmptyView()
                    }
                }
            }
        #else
            WatchView()
        #endif
    }
}
