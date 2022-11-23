import SwiftUI

struct AppLogoView: View {
    var body: some View {
        Image("ProjectLogo")
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}

struct AppLogoView_Previews: PreviewProvider {
    static var previews: some View {
        AppLogoView()
    }
}
