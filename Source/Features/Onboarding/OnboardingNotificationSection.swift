import Components
import EnvironmentModels
import SwiftUI

@MainActor
struct OnboardingNotificationSection: View {
    @Environment(PermissionEnvironmentModel.self) private var permissionEnvironmentModel
    @AppStorage(.notificationOnboardingSectionSkipped) private var notificationOnboardingSectionSkipped = false

    let onContinue: () -> Void

    let color = Color(red: 157 / 255, green: 137 / 255, blue: 219 / 255)

    var body: some View {
        OnboardingSectionContent(onContinue: {
                                     permissionEnvironmentModel.requestPushNotificationAuthorization()
                                 },
                                 onSkip: {
                                     notificationOnboardingSectionSkipped = true
                                     onContinue()
                                 },
                                 color: color,
                                 symbol: "bell.fill",
                                 title: "onboarding.notification.title",
                                 description: "onboarding.notification.description")
            .background(
                AppGradient(color: color),
                alignment: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
            .simultaneousGesture(DragGesture())
            .onChange(of: permissionEnvironmentModel.pushNotificationStatus) {
                onContinue()
            }
    }
}

@MainActor
struct OnboardingSectionContent: View {
    @State private var isMounted = false
    let onContinue: () -> Void
    let onSkip: () -> Void
    let color: Color
    let symbol: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                VStack {
                    Image(systemName: symbol)
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .padding(10)
                        .accessibilityHidden(true)
                }
                .background(in: Circle().inset(by: -20))
                .backgroundStyle(
                    color.gradient
                )
                .foregroundStyle(.white.shadow(.drop(radius: 1, y: 1.5)))
                .padding(20)
                .frame(width: 120, height: 120)

                Text(title)
                    .font(.title)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 16) {
                Button(action: onContinue, label: {
                    Text("labels.continue")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 60)
                        .foregroundColor(.white)
                        .font(.headline)
                        .background(color)
                        .cornerRadius(15)
                })
                Button(action: onSkip, label: {
                    Text("labels.skip")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .foregroundColor(color)
                        .font(.headline)

                })
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .onAppear {
            isMounted = true
        }
    }
}
