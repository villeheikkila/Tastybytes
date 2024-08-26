
import Models
import SwiftUI

struct TabsView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(AdminModel.self) private var adminModel
    @Environment(NotificationModel.self) private var notificationModel
    @Environment(ProfileModel.self) private var profileModel
    @State private var selectedTab: Tabs = .activity

    private var isAdmin: Bool {
        profileModel.hasRole(.admin) || profileModel.hasRole(.superAdmin)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tabs.activity.tab
            Tabs.discover.tab
            Tabs.notifications.tab
                .badge(notificationModel.unreadCount)
            if isAdmin {
                Tabs.admin.tab
                    .badge(adminModel.notificationCount)
            }
            Tabs.profile.tab
        }
        .tabViewStyle(.sidebarAdaptable)
        .sensoryFeedback(.selection, trigger: selectedTab)
        .onOpenURL { url in
            if let tab = TabUrlHandler(url: url, deeplinkSchemes: appModel.infoPlist.deeplinkSchemes).tab {
                selectedTab = tab
            }
        }
    }
}
