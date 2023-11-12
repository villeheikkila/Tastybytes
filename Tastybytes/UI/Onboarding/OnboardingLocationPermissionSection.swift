import EnvironmentModels
import SwiftUI

struct OnboardingLocationPermissionSection: View {
    @Environment(LocationEnvironmentModel.self) private var locationEnvironmentModel
    @State private var isMounted = false

    let onContinue: () -> Void

    var body: some View {
        VStack {
            Image(systemName: "location.fill")
                .resizable()
                .scaledToFit()
                .symbolEffect(.bounce.up, value: isMounted)
                .frame(width: 70, height: 70)
                .padding(.top, 80)
                .onTapGesture {
                    isMounted.toggle()
                }

            Text("Access to location")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top, 20)

            Text("Location is only used to suggest you venues for your check-ins and show near by activity")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing], 30)
                .padding(.top, 10)

            Spacer()
            Button(action: {
                locationEnvironmentModel.requestLocationAuthorization()
            }, label: {
                Text("Continue")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 60)
                    .foregroundColor(.white)
                    .font(.headline)
                    .background(Color.blue)
                    .cornerRadius(15)
            })
            .padding([.leading, .trailing], 20)
            Button(action: {
                onContinue()
            }, label: {
                Text("Skip")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .foregroundColor(.blue)
                    .font(.headline)
            })
            .padding([.leading, .trailing], 20)
            .padding(.top, 20)
        }
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
