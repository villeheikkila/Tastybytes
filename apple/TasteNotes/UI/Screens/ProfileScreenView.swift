import SwiftUI

struct ProfileScreenView: View {
  let profile: Profile
  @State private var scrollToTop = 0

  var body: some View {
    ProfileView(profile: profile, scrollToTop: $scrollToTop)
  }
}
