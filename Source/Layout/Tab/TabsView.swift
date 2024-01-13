import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct TabsView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var tabManager = TabManager()

    private var shownTabs: [Tab] {
        if profileEnvironmentModel.hasRole(.admin) {
            [.activity, .discover, .notifications, .admin, .profile]
        } else {
            [.activity, .discover, .notifications, .profile]
        }
    }


    var body: some View {
        TabView(selection: $tabManager.selection) {
            tabs
        }
        .sensoryFeedback(.selection, trigger: tabManager.selection)
        .simultaneousGesture(switchTabGesture)
        .environment(tabManager)
        .onOpenURL { url in
            if let tab = TabUrlHandler(url: url, deeplinkSchemes: appEnvironmentModel.infoPlist.deeplinkSchemes).tab {
                tabManager.selection = tab
            }
        }
    }

    private var tabs: some View {
        ForEach(shownTabs) { tab in
            RouterWrapper {
                tab.view
            }
            .tabItem {
                tab.label
            }
            .tag(tab)
            .badge(badge())
        }
    }
    
    private func badge() -> Int {
        switch tabManager.selection {
        case .notifications:
            notificationEnvironmentModel.unreadCount
        default:
            0
        }
    }

    private let switchTabGestureRangeDistance: Double = 50

    var switchTabGesture: some Gesture {
        DragGesture(minimumDistance: switchTabGestureRangeDistance)
            .onEnded { value in
                if value.translation.width < -switchTabGestureRangeDistance,
                   value.translation.width > -(3 * switchTabGestureRangeDistance),
                   tabManager.selection.rawValue < shownTabs.count - 1
                {
                    if let tab = Tab(rawValue: tabManager.selection.rawValue + 1) {
                        tabManager.selection = tab
                    }
                } else if value.translation.width > switchTabGestureRangeDistance,
                          value.translation.width < 3 * switchTabGestureRangeDistance, tabManager.selection.rawValue > 0
                {
                    if let tab = Tab(rawValue: tabManager.selection.rawValue - 1) {
                        tabManager.selection = tab
                    }
                }
            }
    }
}
