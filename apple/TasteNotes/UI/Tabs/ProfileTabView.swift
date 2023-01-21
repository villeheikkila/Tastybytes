import Charts
import GoTrue
import PhotosUI
import SwiftUI

struct ProfileTabView: View {
  @StateObject private var router = Router()
  @EnvironmentObject private var profileManager: ProfileManager
  @Binding var backToRoot: Tab

  var body: some View {
    NavigationStack(path: $router.path) {
      WithRoutes {
        ProfileScreenView(profile: profileManager.getProfile())
      }
      .onChange(of: $backToRoot.wrappedValue) { backToRoot in
        if backToRoot == .profile {
          router.reset()
        }
      }
    }
  }
}
