import SwiftUI
import Components

struct AppUnderMaintenanceState: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        ContentUnavailableView {
            Label("app.underMaintenance.title", systemImage: "wrench.and.screwdriver")
        } description: {
            Text("app.underMaintenance.description")
        } actions: {
            AsyncButton("app.underMaintenance.refreshButton", systemImage: "arrow.triangle.2.circlepath", action: {
                await appModel.initialize(reset: true)
            })
            .foregroundColor(.black)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            AppGradientView(color: Color(.sRGB, red: 255 / 255, green: 165 / 255, blue: 0 / 255, opacity: 1)), // Orange color
            alignment: .bottom
        )
        .ignoresSafeArea()
    }
}
