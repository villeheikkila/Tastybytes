import Components
import EnvironmentModels
import Models
import PhotosUI
import SwiftUI

@MainActor
struct ProfileSettingsScreen: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var username = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var usernameIsAvailable = false
    @State private var isLoading = false

    var canUpdateUsername: Bool {
        username.count >= 3 && usernameIsAvailable && !username.isEmpty && !isLoading
    }

    var body: some View {
        Form {
            profileSection
            profileDisplaySettings
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: username) {
            usernameIsAvailable = false
            isLoading = true
        }
        .task(id: username, milliseconds: 300) { @MainActor in
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
            LabeledTextField(title: "Username", text: $username)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            LabeledTextField(title: "First Name", text: $firstName)
            LabeledTextField(title: "Last Name", text: $lastName)

            if profileEnvironmentModel.hasChanged(username: username, firstName: firstName, lastName: lastName) {
                ProgressButton(
                    "Update",
                    action: { await profileEnvironmentModel.updateProfile(update: Profile.UpdateRequest(
                        username: username,
                        firstName: firstName,
                        lastName: lastName
                    )) }
                ).disabled(!canUpdateUsername)
            }
        } header: {
            Text("Identity")
        } footer: {
            Text("These values are used in your personal page and can be seen by other users.")
        }
        .headerProminence(.increased)
    }

    private var profileDisplaySettings: some View {
        Section {
            Toggle("Show full name", isOn: .init(get: {
                profileEnvironmentModel.showFullName
            }, set: { newValue in
                profileEnvironmentModel.showFullName = newValue
                Task { await profileEnvironmentModel.updateDisplaySettings() }
            }))
        } footer: {
            Text("Use your full name as a display name across the interface. This only takes effect if both first name and last name are provided.")
        }
    }
}
