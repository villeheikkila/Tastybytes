import SwiftUI

struct AppLogoView: View {
    let size: Double

    init(size: Double? = nil) {
        self.size = size ?? min(UIScreen.main.bounds.width / 4, 300)
    }

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
