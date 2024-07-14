import Components
import EnvironmentModels
import Models
import SwiftUI

struct ProfileSettingsScreen: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var username = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var usernameIsAvailable = false
    @State private var isLoading = false

    private var canUpdateUsername: Bool {
        username.count >= 3 && !isLoading && usernameIsAvailable
    }

    private var canUpdate: Bool {
        canUpdateUsername && profileEnvironmentModel.hasChanged(username: username, firstName: firstName, lastName: lastName)
    }

    var body: some View {
        Form {
            ProfileAvatarPickerSectionView()
            ProfileInfoSettingSectionsView(usernameIsAvailable: $usernameIsAvailable, username: $username, firstName: $firstName, lastName: $lastName, isLoading: $isLoading)
            if profileEnvironmentModel.firstName != nil, profileEnvironmentModel.lastName != nil {
                nameVisibilitySection
            }
            Section {
                AsyncButton(
                    "settings.profile.update",
                    action: {
                        await profileEnvironmentModel.updateProfile(update: .init(
                            username: username,
                            firstName: firstName,
                            lastName: lastName
                        ))
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
                profileEnvironmentModel.showFullName
            }, set: { newValue in
                profileEnvironmentModel.showFullName = newValue
                Task { await profileEnvironmentModel.updateDisplaySettings() }
            }))
        } footer: {
            Text("settings.profile.useFullName.description")
        }
    }
}
