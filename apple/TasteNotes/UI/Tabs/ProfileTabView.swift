import Charts
import GoTrue
import PhotosUI
import SwiftUI

struct ProfileTabView: View {
  @StateObject private var router = Router()
  @State private var scrollToTop = 0
  @EnvironmentObject private var profileManager: ProfileManager
  @Binding var resetNavigationStackOnTab: Tab?

  var body: some View {
    NavigationStack(path: $router.path) {
      WithRoutes {
        ProfileView(profile: profileManager.getProfile(), scrollToTop: $scrollToTop)
      }
      .onChange(of: $resetNavigationStackOnTab.wrappedValue) { tab in
        if tab == .profile {
          if router.path.isEmpty {
            scrollToTop += 1
          } else {
            router.reset()
          }
          resetNavigationStackOnTab = nil
        }
      }
    }
  }
}
