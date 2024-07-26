
import SwiftUI

struct OnboardingScreen: View {
    @Environment(ProfileModel.self) private var profileModel
    @State private var currentTab: OnboardingSection

    init(initialTab: OnboardingSection) {
        _currentTab = State(initialValue: initialTab)
    }

    var showProfileSection: Bool {
        !profileModel.isOnboarded
    }

    var body: some View {
        RouterProvider(enableRoutingFromURLs: false) {
            TabView(selection: .init(get: { currentTab }, set: { newTab in
                currentTab = newTab
            })) {
                if showProfileSection {
                    OnboardingProfileSection()
                        .tag(OnboardingSection.profile)
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .ignoresSafeArea(edges: .bottom)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
        }
    }
}

enum OnboardingSection: Int, Identifiable, Hashable {
    case profile

    var id: Int {
        rawValue
    }
}
