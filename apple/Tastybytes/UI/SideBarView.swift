import SwiftUI

enum SiderBarTab: Int, Identifiable, Hashable, CaseIterable {
  case activity, discover, notifications, admin, profile, friends, settings

  var id: Int {
    rawValue
  }

  @ViewBuilder var label: some View {
    switch self {
    case .activity:
      Label("Activity", systemImage: "list.star")
    case .discover:
      Label("Discover", systemImage: "magnifyingglass")
    case .notifications:
      Label("Notifications", systemImage: "bell")
    case .admin:
      Label("Admin", systemImage: "exclamationmark.lock.fill")
    case .profile:
      Label("Profile", systemImage: "person.fill")
    case .friends:
      Label("Friends", systemImage: "person.2.fill")
    case .settings:
      Label("Settings", systemImage: "gearshape.fill")
    }
  }
}

struct SideBarView: View {
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var appDataManager: AppDataManager
  @Environment(\.orientation) private var orientation
  @StateObject private var sheetManager = SheetManager()
  @State private var selection: SiderBarTab? = SiderBarTab.activity
  @State private var scrollToTop: Int = 0
  @StateObject private var router = Router(tab: Tab.activity)

  private var shownTabs: [SiderBarTab] {
    if profileManager.hasRole(.admin) {
      return SiderBarTab.allCases
    } else {
      return SiderBarTab.allCases.filter { $0 != .admin }
    }
  }

  private var isPortrait: Bool {
    [.portrait, .portraitUpsideDown].contains(orientation)
  }

  private var columnVisibility: NavigationSplitViewVisibility {
    isPortrait ? .automatic : .all
  }

  var body: some View {
    NavigationSplitView(columnVisibility: .constant(columnVisibility)) {
      List(selection: $selection) {
        HStack(alignment: .firstTextBaseline) {
          Text(Config.appName)
            .font(Font.custom("Comfortaa-Bold", size: 24)).bold()
          Spacer()
        }
        Color.clear.frame(width: 0, height: 12)
        ForEach(shownTabs) { newTab in
          Button(action: {
            feedbackManager.trigger(.selection)
            if newTab == selection {
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                scrollToTop += 1
                router.reset()
              }
            } else {
              selection = newTab
            }
          }, label: {
            newTab.label
          })
          .tag(newTab.id)
        }
      }
      .listStyle(.sidebar)
      .navigationSplitViewColumnWidth(220)
    } detail: {
      NavigationStack(path: $router.path) {
        switch selection {
        case .activity:
          ActivityScreen(scrollToTop: $scrollToTop, navigateToDiscoverTab: {
            selection = .discover
          })
        case .discover:
          DiscoverScreen(scrollToTop: $scrollToTop)
        case .notifications:
          NotificationScreen(scrollToTop: $scrollToTop)
        case .admin:
          AdminScreen()
        case .profile:
          CurrentProfileScreen(scrollToTop: $scrollToTop)
        case .friends:
          CurrentUserFriendsScreen()
        case .settings:
          SettingsScreen()
        case nil:
          EmptyView()
        }
      }
      .navigationDestination(for: Screen.self) { screen in
        screen.view
      }
    }
    .navigationSplitViewStyle(.balanced)
    .onOpenURL { url in
      if let tab = url.sidebarTab {
        selection = tab
      }
    }
    .environmentObject(router)
    .environmentObject(sheetManager)
    .toast(isPresenting: $feedbackManager.show) {
      feedbackManager.toast
    }
    .sheet(item: $sheetManager.sheet) { sheet in
      NavigationStack {
        sheet.view
      }
      .presentationDetents(sheet.detents)
      .presentationCornerRadius(sheet.cornerRadius)
      .presentationBackground(sheet.background)
      .presentationDragIndicator(.visible)
      .environmentObject(sheetManager)
      .environmentObject(profileManager)
      .environmentObject(appDataManager)
      .environmentObject(feedbackManager)
      .toast(isPresenting: $feedbackManager.show) {
        feedbackManager.toast
      }
      .sheet(item: $sheetManager.nestedSheet, content: { nestedSheet in
        NavigationStack {
          nestedSheet.view
        }
        .presentationDetents(nestedSheet.detents)
        .presentationCornerRadius(nestedSheet.cornerRadius)
        .presentationBackground(nestedSheet.background)
        .presentationDragIndicator(.visible)
        .environmentObject(sheetManager)
        .environmentObject(profileManager)
        .environmentObject(appDataManager)
        .environmentObject(feedbackManager)
        .toast(isPresenting: $feedbackManager.show) {
          feedbackManager.toast
        }
      })
    }
  }

  private func getBadgeByTab(_ tab: Tab) -> Int {
    switch tab {
    case .notifications:
      return notificationManager.unreadCount
    default:
      return 0
    }
  }
}
