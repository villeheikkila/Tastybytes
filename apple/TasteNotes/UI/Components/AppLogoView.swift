import SwiftUI

struct AppLogoView: View {
    var body: some View {
        Image("ProjectLogo")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 120, height: 120)
    }
}

struct AppLogoView_Previews: PreviewProvider {
    static var previews: some View {
        AppLogoView()
    }
}
