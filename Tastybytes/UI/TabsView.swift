import SwiftUI

struct TabsView: View {
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(FeedbackManager.self) private var feedbackManager
    @Environment(ProfileManager.self) private var profileManager
    @AppStorage(.selectedTab) private var selection = Tab.activity
    @State private var resetNavigationOnTab: Tab?

    private let switchTabGestureRangeDistance: Double = 50

    private var shownTabs: [Tab] {
        if profileManager.hasRole(.admin) {
            [.activity, .discover, .notifications, .admin, .profile]
        } else {
            [.activity, .discover, .notifications, .profile]
        }
    }

    var switchTabGesture: some Gesture {
        DragGesture(minimumDistance: switchTabGestureRangeDistance)
            .onEnded { value in
                if value.translation.width < -switchTabGestureRangeDistance,
                   value.translation.width > -(3 * switchTabGestureRangeDistance),
                   selection.rawValue < shownTabs.count - 1
                {
                    if let tab = Tab(rawValue: selection.rawValue + 1) {
                        feedbackManager.trigger(.selection)
                        selection = tab
                    }
                } else if value.translation.width > switchTabGestureRangeDistance,
                          value.translation.width < 3 * switchTabGestureRangeDistance, selection.rawValue > 0
                {
                    if let tab = Tab(rawValue: selection.rawValue - 1) {
                        feedbackManager.trigger(.selection)
                        selection = tab
                    }
                }
            }
    }

    var body: some View {
        TabView(selection: .init(get: {
            selection
        }, set: { newTab in
            feedbackManager.trigger(.selection)
            if newTab == selection {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    resetNavigationOnTab = selection
                }
            } else {
                selection = newTab
            }
        })) {
            ForEach(shownTabs) { tab in
                tab.view(selectedTab: $selection, $resetNavigationOnTab)
                    .tabItem {
                        tab.label
                    }
                    .tag(tab)
                    .badge(getBadgeByTab(tab))
            }
        }
        .simultaneousGesture(switchTabGesture)
        .onOpenURL { url in
            if let tab = url.tab {
                selection = tab
            }
        }
    }

    private func getBadgeByTab(_ tab: Tab) -> Int {
        switch tab {
        case .notifications:
            notificationManager.unreadCount
        default:
            0
        }
    }
}
