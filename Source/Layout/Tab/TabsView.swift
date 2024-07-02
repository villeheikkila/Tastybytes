import EnvironmentModels
import Models
import SwiftUI

struct TabsView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var selection = Tab.activity

    private var shownTabs: [Tab] {
        if profileEnvironmentModel.hasRole(.admin) {
            [.activity, .discover, .notifications, .admin, .profile]
        } else {
            [.activity, .discover, .notifications, .profile]
        }
    }

    var body: some View {
        TabView(selection: $selection) {
            tabs
        }
        .tabViewStyle(.sidebarAdaptable)
        .sensoryFeedback(.selection, trigger: selection)
        .onOpenURL { url in
            if let tab = TabUrlHandler(url: url, deeplinkSchemes: appEnvironmentModel.infoPlist.deeplinkSchemes).tab {
                selection = tab
            }
        }
    }

    private var tabs: some View {
        ForEach(shownTabs) { tab in
            RouterProvider(enableRoutingFromURLs: true) {
                tab.view
            }
            .tabItem {
                tab.label
            }
            .tag(tab)
            .badge(badge(tab))
        }
    }

    private func badge(_ tab: Tab) -> Int {
        switch tab {
        case .notifications:
            notificationEnvironmentModel.unreadCount
        default:
            0
        }
    }
}
