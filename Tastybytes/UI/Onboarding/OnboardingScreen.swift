import EnvironmentModels
import SwiftUI

struct OnboardingScreen: View {
    @AppStorage(.isOnboardedOnDevice) private var isOnboardedOnDevice = false
    @Environment(SplashScreenEnvironmentModel.self) private var splashScreenEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(PermissionEnvironmentModel.self) private var permissionEnvironmentModel
    @Environment(LocationEnvironmentModel.self) private var locationEnvironmentModel
    @State private var currentTab: OnboardingSection

    init(initialTab _: OnboardingSection) {
        // _currentTab = State(initialValue: initialTab)
        _currentTab = State(initialValue: .profile)
    }

    func finishOnboarding() {
        Task {
            await profileEnvironmentModel.onboardingUpdate()
            isOnboardedOnDevice = true
        }
    }

    var showProfileSection: Bool {
        !profileEnvironmentModel.isOnboarded
    }

    var showNotificationSection: Bool {
        permissionEnvironmentModel.pushNotificationStatus == .notDetermined
    }

    var showLocationSection: Bool {
        locationEnvironmentModel.locationsStatus == .notDetermined
    }

    var body: some View {
        TabView(selection: .init(get: { currentTab }, set: { newTab in
            currentTab = newTab
        })) {
            if showProfileSection {
                OnboardingProfileSection(onContinue: {
                    if showNotificationSection {
                        currentTab = .notifications
                    } else if showLocationSection {
                        currentTab = .location
                    } else {
                        finishOnboarding()
                    }
                })
                .tag(OnboardingSection.profile)
            }
            if showNotificationSection {
                OnboardingNotificationSection(onContinue: {
                    if showLocationSection {
                        currentTab = .location
                    } else {
                        finishOnboarding()
                    }
                })
                .tag(OnboardingSection.notifications)
            }
            if showLocationSection {
                OnboardingLocationPermissionSection(onContinue: {
                    finishOnboarding()
                })
                .tag(OnboardingSection.location)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
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
