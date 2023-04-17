import PhotosUI
import SwiftUI

struct ProfileSettingsScreen: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var feedbackManager: FeedbackManager

  var body: some View {
    Form {
      profileSection
      profileDisplaySettings
      privacySection
    }
    .navigationTitle("Profile")
  }

  private var profileSection: some View {
    Section {
      TextField("Username", text: $profileManager.username)
        .autocapitalization(.none)
        .disableAutocorrection(true)
      TextField("First Name", text: $profileManager.firstName)
      TextField("Last Name", text: $profileManager.lastName)

      if profileManager.profileHasChanged {
        ProgressButton("Update", action: { await profileManager.updateProfile(onSuccess: {
          await profileManager.refresh()
          feedbackManager.toggle(.success("Profile updated!"))
        }, onFailure: { error in
          feedbackManager.toggle(.error(.custom(error.localizedDescription)))
        }) }).transition(.slide)
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
