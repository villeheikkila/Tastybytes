import EnvironmentModels
import SwiftUI

struct OnboardingScreen: View {
    @AppStorage(.isOnboardedOnDevice) private var isOnboardedOnDevice = false
    @Environment(SplashScreenEnvironmentModel.self) private var splashScreenEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(PermissionEnvironmentModel.self) private var permissionEnvironmentModel
    @State private var currentTab: OnboardingSection

    init(initialTab: OnboardingSection) {
        _currentTab = State(initialValue: initialTab)
    }

    func finishOnboarding() {
        Task {
            await profileEnvironmentModel.onboardingUpdate()
            isOnboardedOnDevice = true
        }
    }

    var body: some View {
        TabView(selection: .init(get: { currentTab }, set: { newTab in
            currentTab = newTab
        })) {
            if !profileEnvironmentModel.isOnboarded {
                OnboardingProfileSection(onContinue: {
                    currentTab = .avatar
                })
                .tag(OnboardingSection.profile)
                OnboardingAvatarScreen(onContinue: {})
                    .tag(OnboardingSection.avatar)
            }
            if permissionEnvironmentModel.pushNotificationStatus == .notDetermined {
                OnboardingNotificationSection(onContinue: {
                    if permissionEnvironmentModel.locationsStatus == .notDetermined {
                        currentTab = .location
                    } else {
                        finishOnboarding()
                    }
                })
                .tag(OnboardingSection.notifications)
            }
            if permissionEnvironmentModel.locationsStatus == .notDetermined {
                OnboardingLocationPermissionSection(onContinue: {
                    finishOnboarding()
                })
                .tag(OnboardingSection.location)
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .never))
        .task {
            await splashScreenEnvironmentModel.dismiss()
        }
    }
}

enum OnboardField {
    case username, firstName, lastName
}

enum OnboardingSection: Int, Identifiable, Hashable {
    case profile, avatar, notifications, location

    var id: Int {
        rawValue
    }
}
