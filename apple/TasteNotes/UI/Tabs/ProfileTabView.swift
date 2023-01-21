import Charts
import GoTrue
import PhotosUI
import SwiftUI

struct ProfileTabView: View {
  let profile: Profile
  @StateObject private var routeManager = RouterPath()

  var body: some View {
    NavigationStack(path: $routeManager.path) {
      WithRoutes {
        ProfileScreenView(profile: profile)
      }
    }
  }
}
