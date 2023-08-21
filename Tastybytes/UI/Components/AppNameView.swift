import Models
import SwiftUI

struct AppNameView: View {
    var body: some View {
        Text(Config.appName)
            .font(Font.custom("Comfortaa-Bold", size: 28))
            .bold()
    }
}

#Preview {
    AppNameView()
}
