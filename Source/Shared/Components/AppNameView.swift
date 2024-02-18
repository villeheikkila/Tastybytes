import EnvironmentModels
import Models
import SwiftUI

struct AppNameView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel

    var body: some View {
        Text(appEnvironmentModel.infoPlist.appName)
            .font(.custom("Comfortaa-Bold", size: 28))
            .bold()
    }
}

#Preview {
    AppNameView()
}
