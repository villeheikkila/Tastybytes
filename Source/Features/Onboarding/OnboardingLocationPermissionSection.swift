import Components
import EnvironmentModels
import SwiftUI

@MainActor
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
                                 title: "onboarding.locationPermission.accessToLocation.title",
                                 description: "onboarding.locationPermission.accessToLocation.description")
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
