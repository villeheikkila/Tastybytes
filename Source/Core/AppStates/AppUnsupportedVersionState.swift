
import Extensions
import SwiftUI

struct AppUnsupportedVersionState: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        ContentUnavailableView("app.unsupportedVersion.title", systemImage: "arrow.triangle.2.circlepath", description: Text("app.unsupportedVersion.description"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                if let appleStoreUrl = appModel.appConfig?.appleStoreUrl {
                    Link(destination: appleStoreUrl) {
                        Text("app.unsupportedVersion.openAppStore.label")
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .font(.headline)
                    .background(.accent)
                    .cornerRadius(15)
                    .padding()
                    .padding()
                }
            }
            .background(
                AppGradientView(color: Color(.sRGB, red: 130 / 255, green: 135 / 255, blue: 230 / 255, opacity: 1)),
                alignment: .bottom
            )
            .ignoresSafeArea()
    }
}

#Preview {
    AppUnsupportedVersionState()
}
