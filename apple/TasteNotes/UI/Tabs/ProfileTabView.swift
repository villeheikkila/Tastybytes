import Charts
import GoTrue
import PhotosUI
import SwiftUI

struct ProfileTabView: View {
  let profile: Profile
  @StateObject private var router = Router()

  var body: some View {
    NavigationStack(path: $router.path) {
      WithRoutes {
        ProfileScreenView(profile: profile)
      }
    }
  }
}
