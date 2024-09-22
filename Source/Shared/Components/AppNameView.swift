import SwiftUI

struct AppNameView: View {
    @Environment(AppModel.self) private var appModel
    let size: Double

    init(size: Double = 28) {
        self.size = size
    }

    var body: some View {
        Text(appModel.infoPlist.appName)
            .font(.custom("Comfortaa-Bold", size: size))
            .bold()
    }
}
