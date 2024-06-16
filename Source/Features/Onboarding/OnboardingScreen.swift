import EnvironmentModels
import SwiftUI

@MainActor
struct OnboardingScreen: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
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

enum OnboardingSection: Int, Identifiable, Hashable {
    case profile

    var id: Int {
        rawValue
    }
}
