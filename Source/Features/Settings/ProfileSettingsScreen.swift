import Components
import EnvironmentModels
import Models
import PhotosUI
import SwiftUI

struct ProfileSettingsScreen: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var username = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var usernameIsAvailable = false
    @State private var isLoading = false

    private var canUpdateUsername: Bool {
        username.count >= 3 && usernameIsAvailable && !username.isEmpty && !isLoading
    }

    var body: some View {
        Form {
            profileSection
            profileDisplaySettings
        }
        .navigationTitle("settings.profile.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: username) {
            usernameIsAvailable = false
            isLoading = true
        }
        .task(id: username, milliseconds: 300) {
            guard username.count >= 3 else { return }
            let isAvailable = await profileEnvironmentModel
                .checkIfUsernameIsAvailable(username: username)
            withAnimation {
                usernameIsAvailable = isAvailable
                isLoading = false
            }
        }
        .onAppear {
            username = profileEnvironmentModel.username
            firstName = profileEnvironmentModel.firstName ?? ""
            lastName = profileEnvironmentModel.lastName ?? ""
        }
    }

    private var profileSection: some View {
        Section {
            LabeledTextFieldView(title: "settings.profile.username", text: $username)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            LabeledTextFieldView(title: "settings.profile.firstName", text: $firstName)
            LabeledTextFieldView(title: "settings.profile.lastName", text: $lastName)

            if profileEnvironmentModel.hasChanged(username: username, firstName: firstName, lastName: lastName) {
                AsyncButton(
                    "settings.profile.update",
                    action: { await profileEnvironmentModel.updateProfile(update: Profile.UpdateRequest(
                        username: username,
                        firstName: firstName,
                        lastName: lastName
                    )) }
                ).disabled(!canUpdateUsername)
            }
        } header: {
            Text("settings.profile.section.identity.title")
        } footer: {
            Text("settings.profile.section.identity.description")
        }
        .headerProminence(.increased)
    }

    private var profileDisplaySettings: some View {
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
