import EnvironmentModels
import Models
import Repositories
import SwiftUI

enum SiderBarTab: Int, Identifiable, Hashable, CaseIterable {
    case activity, discover, notifications, admin, profile, friends, settings

    var id: Int {
        rawValue
    }

    @ViewBuilder var label: some View {
        switch self {
        case .activity:
            Label("activity.navigationTitle", systemImage: "list.star")
        case .discover:
            Label("discover.navigationTitle", systemImage: "magnifyingglass")
        case .notifications:
            Label("notifications.navigationTitle", systemImage: "bell")
        case .admin:
            Label("admin.navigationTitle", systemImage: "exclamationmark.lock.fill")
        case .profile:
            Label("profile.navigationTitle", systemImage: "person.fill")
        case .friends:
            Label("friends.navigationTitle", systemImage: "person.2.fill")
        case .settings:
            Label("settings.navigationTitle", systemImage: "gearshape.fill")
        }
    }
}

@MainActor
struct SideBarView: View {
    @Environment(Repository.self) private var repository
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(\.isPortrait) private var isPortrait
    @State private var selection: SiderBarTab? = SiderBarTab.activity
    @State private var scrollToTop: Int = 0
    @State private var router = Router()

    private var shownTabs: [SiderBarTab] {
        if profileEnvironmentModel.hasRole(.admin) {
            SiderBarTab.allCases
        } else {
            SiderBarTab.allCases.filter { $0 != .admin }
        }
    }

    var body: some View {
        @Bindable var feedbackEnvironmentModel = feedbackEnvironmentModel
        GeometryReader { geometry in
            NavigationSplitView(columnVisibility: .init(get: {
                isPortrait ? .doubleColumn : geometry.size.width < 1100 ? .automatic : .all
            }, set: { _ in
            }), sidebar: {
                List(shownTabs, selection: $selection) { newTab in
                    NavigationLink(value: newTab) {
                        newTab.label
                    }
                    .tag(newTab.id)
                }
                .listStyle(.sidebar)
            }, content: {
                switch selection {
                case .activity:
                    ActivityScreen(repository: repository, scrollToTop: $scrollToTop)
                        .navigationTitle("activity.navigationTitle")
                        .navigationBarTitleDisplayMode(.inline)
                case .discover:
                    DiscoverScreen(scrollToTop: $scrollToTop)
                        .navigationBarTitleDisplayMode(.inline)
                case .notifications:
                    NotificationScreen(scrollToTop: $scrollToTop)
                case .admin:
                    AdminScreen()
                        .navigationBarTitleDisplayMode(.inline)
                case .profile:
                    ProfileView(profile: profileEnvironmentModel.profile, scrollToTop: $scrollToTop, isCurrentUser: true)
                        .navigationTitle(profileEnvironmentModel.profile.preferredName)
                        .navigationBarTitleDisplayMode(.inline)
                case .friends:
                    CurrentUserFriendsScreen(showToolbar: false)
                        .navigationBarTitleDisplayMode(.inline)
                case .settings:
                    SettingsScreen()
                        .navigationBarTitleDisplayMode(.inline)
                case nil:
                    EmptyView()
                }
            }, detail: {
                NavigationStack(path: $router.path) {
                    EmptyView()
                }
                .navigationDestination(for: Screen.self) { screen in
                    screen.view
                }
            })
            .navigationSplitViewStyle(.balanced)
            .navigationBarTitleDisplayMode(.inline)
            .onOpenURL { url in
                if let tab = TabUrlHandler(url: url, deeplinkSchemes: appEnvironmentModel.infoPlist.deeplinkSchemes).sidebarTab {
                    selection = tab
                }
            }
            .sensoryFeedback(.selection, trigger: selection)
            .environment(router)
            .environment(appEnvironmentModel)
            .toast(isPresenting: $feedbackEnvironmentModel.show) {
                feedbackEnvironmentModel.toast
            }
        }
    }

    private func getBadgeByTab(_ tab: Tab) -> Int {
        switch tab {
        case .notifications:
            notificationEnvironmentModel.unreadCount
        default:
            0
        }
    }
}
