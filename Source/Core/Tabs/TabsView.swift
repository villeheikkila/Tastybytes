
import Models
import SwiftUI

struct TabsView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(AdminModel.self) private var adminModel
    @Environment(NotificationModel.self) private var notificationModel
    @Environment(ProfileModel.self) private var profileModel
    @State private var selection = Tab.activity

    private var shownTabs: [Tab] {
        if profileModel.hasRole(.admin) || profileModel.hasRole(.superAdmin) {
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
            if let tab = TabUrlHandler(url: url, deeplinkSchemes: appModel.infoPlist.deeplinkSchemes).tab {
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
            notificationModel.unreadCount
        case .admin:
            adminModel.notificationCount
        default:
            0
        }
    }
}
