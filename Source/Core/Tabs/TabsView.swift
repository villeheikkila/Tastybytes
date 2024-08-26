
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
            Tab(Tabs.activity.label, systemImage: Tabs.activity.systemImage, value: .activity) {
                Tabs.activity.view
            }
            Tab(Tabs.discover.label, systemImage: Tabs.discover.systemImage, value: .discover) {
                Tabs.discover.view
            }
            Tab(Tabs.notifications.label, systemImage: Tabs.notifications.systemImage, value: .notifications) {
                Tabs.notifications.view
            }
            .badge(notificationModel.unreadCount)
            if isAdmin {
                Tab(Tabs.admin.label, systemImage: Tabs.admin.systemImage, value: .admin) {
                    Tabs.admin.view
                }
                .badge(adminModel.notificationCount)
            }
            Tab(Tabs.profile.label, systemImage: Tabs.profile.systemImage, value: .profile) {
                Tabs.profile.view
            }
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
