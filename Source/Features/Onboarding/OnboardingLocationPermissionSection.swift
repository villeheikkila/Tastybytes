import Components
import EnvironmentModels
import SwiftUI

struct OnboardingLocationPermissionSection: View {
    @Environment(LocationEnvironmentModel.self) private var locationEnvironmentModel
    @AppStorage(.locationOnboardingSectionSkipped) private var locationOnboardingSectionSkipped = false
    @State private var isMounted = false

    let onContinue: () -> Void

    let color = Color(red: 150.0 / 255.0, green: 180.0 / 255.0, blue: 235.0 / 255.0)

    var body: some View {
        OnboardingSectionContent(onContinue: {
                                     locationEnvironmentModel.requestLocationAuthorization()
                                 },
                                 onSkip: {
                                     locationOnboardingSectionSkipped = true
                                     onContinue()
                                 },
                                 color: color,
                                 symbol: "location.fill",
                                 title: "Access to location",
                                 description: "Location is only used to suggest you venues for your check-ins and show near by activity")
            .background(
                AppGradient(color: Color.blue),
                alignment: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
            .simultaneousGesture(DragGesture())
            .onChange(of: locationEnvironmentModel.locationsStatus) { _, newValue in
                if newValue != .notDetermined {
                    onContinue()
                }
            }
            .onAppear {
                isMounted = true
                locationEnvironmentModel.startMonitoringLocationStatus()
            }
            .onDisappear {
                locationEnvironmentModel.stopMonitoringLocationStatus()
            }
    }
}
