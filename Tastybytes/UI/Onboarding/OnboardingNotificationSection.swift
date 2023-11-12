import EnvironmentModels
import SwiftUI

struct OnboardingNotificationSection: View {
    @Environment(PermissionEnvironmentModel.self) private var permissionEnvironmentModel
    @State private var isMounted = false

    let onContinue: () -> Void

    var body: some View {
        VStack {
            Image(systemName: "bell.fill")
                .resizable()
                .scaledToFit()
                .symbolEffect(.bounce.down, value: isMounted)
                .frame(width: 70, height: 70)
                .padding(.top, 80)

            Text("Keep up to date!")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top, 20)

            Text("To keep you updated and informed, we need access to send you notifications.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing], 30)
                .padding(.top, 10)

            Spacer()
            Button(action: {
                permissionEnvironmentModel.requestPushNotificationAuthorization()
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
        .onAppear {
            isMounted = true
        }
        .onChange(of: permissionEnvironmentModel.pushNotificationStatus) {
            onContinue()
        }
    }
}
