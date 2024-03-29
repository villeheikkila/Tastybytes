import EnvironmentModels
import SwiftUI

@MainActor
struct OnboardingScreen: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(PermissionEnvironmentModel.self) private var permissionEnvironmentModel
    @Environment(LocationEnvironmentModel.self) private var locationEnvironmentModel
    @State private var currentTab: OnboardingSection

    init(initialTab: OnboardingSection) {
        _currentTab = State(initialValue: initialTab)
    }

    func finishOnboarding() {
        Task {
            await profileEnvironmentModel.onboardingUpdate()
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
        .ignoresSafeArea(edges: .bottom)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
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
