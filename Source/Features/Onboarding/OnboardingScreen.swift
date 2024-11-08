import Components
import SwiftUI

struct OnboardingScreen: View {
    enum Section {
        case intro, auth, profile
    }

    @Environment(ProfileModel.self) private var profileModel
    @Environment(Router.self) private var router
    @Environment(AppModel.self) private var appModel
    @AppStorage(.profileDeleted) private var profileDeleted = false
    @State private var section: Section = .intro
    @State private var username = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var usernameIsAvailable = false
    @State private var isLoading = false

    private var canProgressToNextStep: Bool {
        username.count >= 3 && usernameIsAvailable && !isLoading
    }

    var body: some View {
        Form {
            switch section {
            case .intro, .auth:
                introAuthView
            case .profile:
                profileView
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: section)
        .background(backgroundView)
        .navigationTitle("onboarding.profile.title")
        .toolbarVisibility(section == .profile ? .visible : .hidden, for: .navigationBar)
        .onChange(of: profileDeleted, initial: true, profileDeletedHandler)
        .onChange(of: profileModel.state, initial: true) { _, newValue in
            if case let .populated(profile) = newValue {
                if !profile.isOnboarded {
                    section = .profile
                }
            }
        }
        .safeAreaInset(edge: .bottom) { bottomView }
    }

    private var introAuthView: some View {
        VStack(alignment: .leading, spacing: 40) {
            OnboardingAppLogoView()
                .padding(.top, 80)
            if section == .intro {
                featureListView
            }
            Spacer()
        }
        .animation(.easeInOut, value: section)
        .listRowBackground(Color.clear)
        .listRowInsets(.init())
    }

    private var featureListView: some View {
        VStack(alignment: .leading, spacing: 30) {
            FeatureListItemView(systemName: "star.fill", title: "Rate & Review", description: "Share your opinions on countless products", colors: [Color.orange, Color.pink])
            FeatureListItemView(systemName: "person.2.fill", title: "Connect", description: "Follow friends and taste influencers", colors: [Color.blue, Color.purple])
            FeatureListItemView(systemName: "sparkles", title: "Discover", description: "Find new flavors tailored to your taste", colors: [Color.green, Color.teal])
        }
        .transition(.opacity)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var profileView: some View {
        ProfileAvatarPickerSectionView()
        ProfileInfoSettingSectionsView(
            usernameIsAvailable: $usernameIsAvailable,
            username: $username,
            firstName: $firstName,
            lastName: $lastName,
            isLoading: $isLoading
        )
    }

    private var backgroundView: some View {
        AppGradientView(color: Color(.sRGB, red: 130 / 255, green: 135 / 255, blue: 230 / 255, opacity: 1))
            .ignoresSafeArea()
    }

    private var bottomView: some View {
        Group {
            switch section {
            case .intro:
                OnboardingButtonView(label: "labels.continue") { section = .auth }
            case .auth:
                authBottomView
            case .profile:
                OnboardingButtonView(label: "labels.continue", action: updateProfile)
                    .disabled(!canProgressToNextStep)
            }
        }
    }

    private var authBottomView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("authentication.welcome \(appModel.infoPlist.appName)")
                .font(.body)
                .fontWeight(.medium)
                .padding(.bottom, 8)
            VStack(spacing: 12) {
                SignInWithAppleView()
                    .frame(height: 52)
                SignInWithGoogleView()
            }
            privacyPolicyAndTermsView
        }
        .padding(.horizontal, 32)
        .transition(.opacity)
    }

    private var privacyPolicyAndTermsView: some View {
        Text("[Privacy Policy](privacyPolicy) [Terms of Service](termsOfService)")
            .font(.caption)
            .environment(\.openURL, OpenURLAction { url in
                if url == URL(string: "privacyPolicy") {
                    router.open(.sheet(.privacyPolicy))
                } else if url == URL(string: "termsOfService") {
                    router.open(.sheet(.termsOfService))
                }
                return .handled
            })
    }

    private func profileDeletedHandler() {
        if profileDeleted {
            router.open(.sheet(.profileDeleteConfirmation))
            profileDeleted = false
        }
    }

    private func updateProfile() {
        Task {
            await profileModel.updateProfile(username: username, firstName: firstName, lastName: lastName)
            await profileModel.onboardingUpdate()
        }
    }
}

struct OnboardingButtonView: View {
    let label: LocalizedStringKey
    let action: () async -> Void

    var body: some View {
        AsyncButton(action: action) {
            Text(label)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 12)
    }
}

struct OnboardingAppLogoView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack {
                Spacer()
                AppLogoView(appIcon: .ramune)
                    .frame(width: 120, height: 120)
                Spacer()
            }
            .overlay(
                SparklesView()
            )
            AppNameView(size: 38)
        }
    }
}

struct FeatureListItemView: View {
    let systemName: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let colors: [Color]

    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: systemName)
                .font(.system(size: 36, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(.rect(cornerRadius: 16, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.leading)
            }
            Spacer()
        }
    }
}
