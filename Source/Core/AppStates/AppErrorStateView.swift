import Components
import EnvironmentModels
import SwiftUI

@MainActor
struct AppErrorStateView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let errors: [Error]

    var label: some View {
        if errors.isNetworkUnavailable {
            ContentUnavailableView("app.networkUnavailable.description", systemImage: "wifi.slash")
        } else {
            ContentUnavailableView("app.error.unexpected.title", systemImage: "exclamationmark.triangle")
        }
    }

    var body: some View {
        label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                ProgressButton(action: {
                    await appEnvironmentModel.initialize(reset: true)
                }, label: {
                    Text("labels.tryAgain")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .font(.headline)
                        .background(Color.accentColor)
                        .cornerRadius(15)
                })
                .disabled(appEnvironmentModel.isInitializing)
                .padding()
                .padding()
            }
            .background(
                AppGradient(color: Color(.sRGB, red: 130 / 255, green: 135 / 255, blue: 230 / 255, opacity: 1)),
                alignment: .bottom
            )
            .ignoresSafeArea()
    }
}

#Preview {
    AppErrorStateView(errors: [])
}
