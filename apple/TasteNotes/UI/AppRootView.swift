import GoTrue
import Supabase
import SwiftUI

struct AppRootView: View {
  @State private var authEvent: AuthChangeEvent?
  @StateObject private var routeManager = RouteManager()
  @StateObject private var profileManager = ProfileManager()
  @EnvironmentObject private var notificationManager: NotificationManager

  var body: some View {
    Group {
      switch authEvent {
      case .signedIn:
        if profileManager.isLoggedIn {
          TabsView()
        }
      case nil:
        ProgressView()
      default:
        AuthenticationScreenView()
      }
    }
    .environmentObject(routeManager)
    .environmentObject(profileManager)
    .preferredColorScheme(profileManager.colorScheme)
    .task {
      profileManager.refresh()
      notificationManager.refresh()
      notificationManager.refreshAPNS()
    }
    .onOpenURL { url in
      if let detailPage = url.detailPage {
        routeManager.fetchAndNavigateTo(detailPage)
      }
    }
    .onOpenURL { url in
      Task { _ = try await supabaseClient.auth.session(from: url) }
    }
    .task {
      for await authEventChange in supabaseClient.auth.authEventChange {
        withAnimation {
          self.authEvent = authEventChange
        }
      }
    }
  }
}
