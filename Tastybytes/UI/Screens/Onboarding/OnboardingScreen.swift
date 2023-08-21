import EnvironmentModels
import SwiftUI

struct OnboardingScreen: View {
    enum Tab: Int, Identifiable, Hashable {
        case welcome, profile, avatar, permission, final

        var id: Int {
            rawValue
        }

        var next: Tab? {
            .init(rawValue: id + 1)
        }
    }

    @Environment(SplashScreenEnvironmentModel.self) private var splashScreenEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @FocusState private var focusedField: OnboardField?
    @State private var currentTab = Tab.welcome

    var body: some View {
        TabView(selection: .init(get: { currentTab }, set: { newTab in
            currentTab = newTab
            focusedField = nil
        })) {
            WelcomeOnboarding(currentTab: $currentTab) {
                withAnimation {
                    currentTab = profileEnvironmentModel.isOnboarded ? Tab.permission : .profile
                }
            }
            .tag(Tab.welcome)
            if !profileEnvironmentModel.isOnboarded {
                ProfileOnboarding(focusedField: _focusedField, currentTab: $currentTab)
                    .tag(Tab.profile)
                AvatarOnboarding(currentTab: $currentTab)
                    .tag(Tab.avatar)
            }
            PermissionOnboarding(currentTab: $currentTab)
                .tag(Tab.permission)
            FinalOnboarding()
                .tag(Tab.final)
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
