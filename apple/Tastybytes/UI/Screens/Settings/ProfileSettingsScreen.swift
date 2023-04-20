import PhotosUI
import SwiftUI

struct ProfileSettingsScreen: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var feedbackManager: FeedbackManager

  @State private var username = ""
  @State private var firstName = ""
  @State private var lastName = ""
  @State private var usernameIsAvailable = true

  var body: some View {
    Form {
      profileSection
      profileDisplaySettings
      privacySection
    }
    .navigationTitle("Profile")
    .onAppear {
      username = profileManager.username
      firstName = profileManager.firstName ?? ""
      lastName = profileManager.lastName ?? ""
    }
  }

  private var profileSection: some View {
    Section {
      TextField("Username", text: $username)
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .onChange(of: username) { _ in
          usernameIsAvailable = true
        }
        .onChange(of: username, debounceTime: 0.3) { newValue in
          guard newValue.count > 1 else { return }
          if username == profileManager.username {
            usernameIsAvailable = true
          } else {
            Task {
              usernameIsAvailable = await profileManager.checkIfUsernameIsAvailable(username: newValue)
            }
          }
        }
      TextField("First Name", text: $firstName)
      TextField("Last Name", text: $lastName)

      if profileManager.hasChanged(username: username, firstName: firstName, lastName: lastName) {
        ProgressButton("Update", action: { await profileManager.updateProfile(update: Profile.UpdateRequest(
          username: username,
          firstName: firstName,
          lastName: lastName
        )) }).disabled(!usernameIsAvailable)
      }
    } header: {
      Text("Profile")
    } footer: {
      Text("These values are used in your personal page and can be seen by other users.")
    }
    .headerProminence(.increased)
  }

  private var profileDisplaySettings: some View {
    Section {
      Toggle("Use Name Instead of Username", isOn: .init(get: {
        profileManager.showFullName
      }, set: { newValue in
        profileManager.showFullName = newValue
        Task { await profileManager.updateDisplaySettings() }
      }))
    } footer: {
      Text("This only takes effect if both first name and last name are provided.")
    }
  }

  private var privacySection: some View {
    Section {
      Toggle("Private Profile", isOn: .init(get: {
        profileManager.isPrivateProfile
      }, set: { newValue in
        profileManager.isPrivateProfile = newValue
        Task { await profileManager.updatePrivacySettings() }
      }))
    } header: {
      Text("Privacy")
    } footer: {
      Text("Private profile hides check-ins and profile page from everyone else but your friends")
    }
    .headerProminence(.increased)
  }
}
