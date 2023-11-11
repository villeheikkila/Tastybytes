import EnvironmentModels
import SwiftUI

struct OnboardingLocationPermissionSection: View {
    @Environment(PermissionEnvironmentModel.self) private var permissionEnvironmentModel

    let onContinue: () -> Void

    var body: some View {
        VStack {
            Image(systemName: "location.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .padding(.top, 80)

            Text("Enable location access to be able to tag near by venues!")
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
                permissionEnvironmentModel.requestLocationAuthorization()
            }, label: {
                Text("Allow Access")
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
                    .frame(height: 60)
                    .foregroundColor(.blue)
                    .font(.headline)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            })
            .padding([.leading, .trailing], 20)
            .padding(.top, 20)
        }
        .simultaneousGesture(DragGesture())
        .onChange(of: permissionEnvironmentModel.locationsStatus) {
            onContinue()
        }
    }
}
