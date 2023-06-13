import PhotosUI
import SwiftUI

struct ProfileSettingsScreen: View {
    @Environment(ProfileManager.self) private var profileManager
    @Environment(FeedbackManager.self) private var feedbackManager

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
        .onAppear {
            username = profileManager.username
            firstName = profileManager.firstName ?? ""
            lastName = profileManager.lastName ?? ""
        }
    }

    private var profileSection: some View {
        Section {
            HStack {
                Text("Username")
                    .foregroundColor(.secondary)
                Spacer()
                TextField("", text: $username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .multilineTextAlignment(.trailing)
                    .onChange(of: username) {
                        usernameIsAvailable = true
                    }
                    .onChange(of: username) {
                        isLoading = true
                    }
                    .onChange(of: username, debounceTime: 0.3) { newValue in
                        guard newValue.count >= 3 else { return }
                        Task {
                            usernameIsAvailable = await profileManager.checkIfUsernameIsAvailable(username: newValue)
                            isLoading = false
                        }
                    }
            }
            LabeledTextField(title: "First Name", text: $firstName)
            LabeledTextField(title: "Last Name", text: $lastName)

            if profileManager.hasChanged(username: username, firstName: firstName, lastName: lastName) {
                ProgressButton("Update", action: { await profileManager.updateProfile(update: Profile.UpdateRequest(
                    username: username,
                    firstName: firstName,
                    lastName: lastName
                ), withFeedback: true) }).disabled(!canUpdateUsername)
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
            Toggle("Use Full Name Instead of Username", isOn: .init(get: {
                profileManager.showFullName
            }, set: { newValue in
                profileManager.showFullName = newValue
                Task { await profileManager.updateDisplaySettings() }
            }))
        } footer: {
            Text("This only takes effect if both first name and last name are provided.")
        }
    }
}
