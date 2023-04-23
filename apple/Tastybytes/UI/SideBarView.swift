import SwiftUI

enum SiderBarTab: Int, Identifiable, Hashable, CaseIterable {
  case activity, search, notifications, admin, profile, friends, settings

  var id: Int {
    rawValue
  }

  @ViewBuilder var label: some View {
    switch self {
    case .activity:
      Label("Activity", systemImage: "list.star")
    case .search:
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

struct Spacing: View {
  var height: CGFloat?
  var width: CGFloat?

  var body: some View {
    if let height {
      Color.clear.frame(height: height)
    } else if let width {
      Color.clear.frame(width: width)
    } else {
      Spacer()
    }
  }
}

struct SideBarView: View {
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.orientation) private var orientation
  @StateObject private var sheetManager = SheetManager()
  @State private var selection: SiderBarTab? = SiderBarTab.activity
  @State private var scrollToTop: Int = 0
  @StateObject private var router = Router()

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
      if isPortrait {
        HStack(alignment: .firstTextBaseline) {
          Color.clear.frame(width: 18, height: 0)
          AppNameView()
          Spacer()
        }
      }
      List(selection: $selection) {
        ForEach(shownTabs) { newTab in
          Button(action: {
            feedbackManager.trigger(.selection)
            if newTab == selection {
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                scrollToTop += 1
                router.path = []
              }
            } else {
              selection = newTab
            }
          }, label: {
            newTab.label
          }).tag(newTab.id)
        }
      }
    } detail: {
      NavigationStack(path: $router.path) {
        switch selection {
        case .activity:
          ActivityScreen(scrollToTop: $scrollToTop)
        case .search:
          DiscoverScreen(scrollToTop: $scrollToTop)
        case .notifications:
          NotificationScreen()
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
    .listStyle(.sidebar)
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
        .toast(isPresenting: $feedbackManager.show) {
          feedbackManager.toast
        }
      })
    }
  }

  private func getBadgeByTab(_ tab: Tab) -> Int {
    switch tab {
    case .notifications:
      return notificationManager.getUnreadCount()
    default:
      return 0
    }
  }
}
