
import Models
import SwiftUI

struct TabsView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(AdminModel.self) private var adminModel
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
                .badge(profileModel.unreadCount)
            if isAdmin {
                Tabs.admin.tab
                    .badge(adminModel.notificationCount)
            }
            Tabs.profile.tab
        }
        .tabViewStyle(.sidebarAdaptable)
        .injectSnacks(alignment: .top)
        .sensoryFeedback(.selection, trigger: selectedTab)
        .ifLet(appModel.subscriptionGroup) { view, subscriptionGroup in
            view.subscriptionStatusTask(for: subscriptionGroup.groupId) { taskStatus in
                await profileModel.onTaskStatusChange(
                    taskStatus: taskStatus,
                    productSubscriptions: subscriptionGroup.subscriptions
                )
            }
        }
        .onOpenURL { url in
            if let tab = TabUrlHandler(url: url, deeplinkSchemes: appModel.infoPlist.deeplinkSchemes).tab {
                selectedTab = tab
            }
        }
    }
}
