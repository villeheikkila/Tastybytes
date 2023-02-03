import SwiftUI

struct AppNameView: View {
  var body: some View {
    Text(Config.appName)
      .font(Font.custom("Menlo-Bold", size: 28))
  }
}

struct AppNameView_Previews: PreviewProvider {
  static var previews: some View {
    AppNameView()
  }
}
