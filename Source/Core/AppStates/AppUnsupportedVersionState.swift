import Components
import EnvironmentModels
import SwiftUI
import Extensions

struct AppUnsupportedVersionState: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    var body: some View {
        ContentUnavailableView("Update needed!", systemImage: "arrow.triangle.2.circlepath", description: Text("Your current app version is no longer supported, please update the app in the App Store"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                if let appleStoreUrl = appEnvironmentModel.appConfig?.appleStoreUrl {
                    Link(destination: appleStoreUrl) {
                        Text("Open App Store")
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .font(.headline)
                    .background(Color.accentColor)
                    .cornerRadius(15)
                    .disabled(appEnvironmentModel.isInitializing)
                    .padding()
                    .padding()
                }
            }
            .background(
                AppGradient(color: Color(.sRGB, red: 130 / 255, green: 135 / 255, blue: 230 / 255, opacity: 1)),
                alignment: .bottom
            )
            .ignoresSafeArea()
    }
}

#Preview {
    AppNetworkUnavailableState()
}
