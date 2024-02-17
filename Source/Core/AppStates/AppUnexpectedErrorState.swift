import Components
import EnvironmentModels
import SwiftUI

struct AppUnexpectedErrorState: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    var body: some View {
        ContentUnavailableView("Unexpected error occured. Please try loading the app again later.", systemImage: "exclamationmark.triangle")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                Button(action: {
                    Task {
                        await appEnvironmentModel.initialize()
                    }
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
    AppNetworkUnavailableState()
}
