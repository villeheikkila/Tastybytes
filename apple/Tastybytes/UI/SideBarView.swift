import SwiftUI

enum SiderBarTab: Int, Identifiable, Hashable, CaseIterable {
  case activity, discover, notifications, admin, profile, friends, settings

  var id: Int {
    rawValue
  }

  @ViewBuilder var label: some View {
    switch self {
    case .activity:
      Label("Activity", systemSymbol: .listStar)
    case .discover:
      Label("Discover", systemSymbol: .magnifyingglass)
    case .notifications:
      Label("Notifications", systemSymbol: .bell)
    case .admin:
      Label("Admin", systemSymbol: .exclamationmarkLockFill)
    case .profile:
      Label("Profile", systemSymbol: .personFill)
    case .friends:
      Label("Friends", systemSymbol: .person2Fill)
    case .settings:
      Label("Settings", systemSymbol: .gearshapeFill)
    }
  }
}

struct SideBarView: View {
  @Environment(Repository.self) private var repository
  @EnvironmentObject private var notificationManager: NotificationManager
  @Environment(FeedbackManager.self) private var feedbackManager
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(AppDataManager.self) private var appDataManager
  @Environment(\.orientation) private var orientation
  @State private var sheetManager = SheetManager()
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
    @Bindable var feedbackManager = feedbackManager
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
    .environment(sheetManager)
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
      .environment(sheetManager)
      .environmentObject(profileManager)
      .environment(appDataManager)
      .environment(feedbackManager)
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
        .environment(sheetManager)
        .environmentObject(profileManager)
        .environment(appDataManager)
        .environment(feedbackManager)
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
