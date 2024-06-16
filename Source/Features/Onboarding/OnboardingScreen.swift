import EnvironmentModels
import SwiftUI

@MainActor
struct OnboardingScreen: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
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

    var showLocationSection: Bool {
        locationEnvironmentModel.locationsStatus == .notDetermined
    }

    var body: some View {
        TabView(selection: .init(get: { currentTab }, set: { newTab in
            currentTab = newTab
        })) {
            if showProfileSection {
                OnboardingProfileSection(onContinue: {
                        finishOnboarding()
                })
                .tag(OnboardingSection.profile)
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
    case profile, avatar

    var id: Int {
        rawValue
    }
}
