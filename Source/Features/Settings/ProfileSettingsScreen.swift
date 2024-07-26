import Components

import Models
import SwiftUI

struct ProfileSettingsScreen: View {
    @Environment(ProfileModel.self) private var profileModel
    @State private var username = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var usernameIsAvailable = false
    @State private var isLoading = false

    private var canUpdateUsername: Bool {
        username.count >= 3 && !isLoading && usernameIsAvailable
    }

    private var canUpdate: Bool {
        canUpdateUsername && profileModel.hasChanged(username: username, firstName: firstName, lastName: lastName)
    }

    var body: some View {
        Form {
            ProfileAvatarPickerSectionView()
            ProfileInfoSettingSectionsView(usernameIsAvailable: $usernameIsAvailable, username: $username, firstName: $firstName, lastName: $lastName, isLoading: $isLoading)
            if profileModel.firstName != nil, profileModel.lastName != nil {
                nameVisibilitySection
            }
            Section {
                AsyncButton(
                    "settings.profile.update",
                    action: {
                        await profileModel.updateProfile(username: username, firstName: firstName, lastName: lastName)
                    }
                ).disabled(!canUpdate)
            }
        }
        .navigationTitle("settings.profile.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var nameVisibilitySection: some View {
        Section {
            Toggle("settings.profile.useFullName.label", isOn: .init(get: {
                profileModel.showFullName
            }, set: { newValue in
                profileModel.showFullName = newValue
                Task { await profileModel.updateDisplaySettings() }
            }))
        } footer: {
            Text("settings.profile.useFullName.description")
        }
    }
}
