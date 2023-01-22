import SwiftUI

struct ProfileScreenView: View {
  @State private var scrollToTop = 0

  let profile: Profile

  var body: some View {
    ProfileView(profile: profile, scrollToTop: $scrollToTop)
  }
}
