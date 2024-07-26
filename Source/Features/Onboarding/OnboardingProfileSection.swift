import Components

import Models
import SwiftUI

struct OnboardingProfileSection: View {
    @Environment(ProfileModel.self) private var profileModel
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
            ProfileAvatarPickerSectionView()
            ProfileInfoSettingSectionsView(usernameIsAvailable: $usernameIsAvailable, username: $username, firstName: $firstName, lastName: $lastName, isLoading: $isLoading)
        }
        .safeAreaInset(edge: .bottom) {
            AsyncButton(action: {
                await profileModel.updateProfile(username: username, firstName: firstName, lastName: lastName)
                await profileModel.onboardingUpdate()
            }, label: {
                Text("labels.continue")
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
            .foregroundColor(.black)
            .disabled(!canProgressToNextStep)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .listStyle(.plain)
        .navigationTitle("onboarding.profile.title")
    }
}
