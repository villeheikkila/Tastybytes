import SwiftUI

struct AppLogoView: View {
  let size = min(UIScreen.main.bounds.width / 4.5, 300)

  var body: some View {
      Image(getCurrentAppIcon().logo)
      .resizable()
      .aspectRatio(contentMode: .fill)
      .frame(width: size, height: size)
      .accessibility(hidden: true)
  }
}

#Preview {
    AppLogoView()
}
