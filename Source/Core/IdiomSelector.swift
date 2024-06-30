import SwiftUI

struct IdiomSelector: View {
    var body: some View {
        #if !os(watchOS)
            OnboardingStateObserver {
                NotificationObserver {
                    switch UIDevice.current.userInterfaceIdiom {
                    case .pad, .mac, .vision:
                        SideBarView()
                    case .phone:
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
