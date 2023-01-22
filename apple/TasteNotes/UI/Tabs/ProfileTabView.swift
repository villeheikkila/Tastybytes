import Charts
import GoTrue
import PhotosUI
import SwiftUI

struct ProfileTabView: View {
  @StateObject private var router = Router()
  @EnvironmentObject private var profileManager: ProfileManager
  @Binding var resetNavigationStackOnTab: Tab?

  var body: some View {
    NavigationStack(path: $router.path) {
      WithRoutes {
        ProfileScreenView(profile: profileManager.getProfile())
      }
      .onChange(of: $resetNavigationStackOnTab.wrappedValue) { tab in
        if tab == .profile {
          router.reset()
          resetNavigationStackOnTab = nil
        }
      }
    }
  }
}
