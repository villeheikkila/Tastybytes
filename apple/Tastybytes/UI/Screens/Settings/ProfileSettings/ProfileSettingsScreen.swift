import PhotosUI
import SwiftUI

struct ProfileSettingsScreen: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var toastManager: ToastManager

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

  var body: some View {
    Form {
      profileSection
      profileDisplaySettings
      privacySection
    }
    .navigationTitle("Profile")
    .task {
      viewModel.getInitialValues(profile: profileManager.get())
    }
  }

  private var profileSection: some View {
    Section {
      TextField("Username", text: $viewModel.username)
        .autocapitalization(.none)
        .disableAutocorrection(true)
      TextField("First Name", text: $viewModel.firstName)
      TextField("Last Name", text: $viewModel.lastName)

      if viewModel.showProfileUpdateButton {
        Button("Update", action: { viewModel.updateProfile(onSuccess: {
          profileManager.refresh()
          toastManager.toggle(.success("Profile updated!"))
        }, onFailure: { error in
          toastManager.toggle(.error(error.localizedDescription))
        }) })
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
      Toggle("Use Name Instead of Username", isOn: $viewModel.showFullName)
        .onChange(of: [viewModel.showFullName].publisher.first()) { _ in
          viewModel.updateDisplaySettings(onUpdate: {
            profileManager.refresh()
          })
        }
    } footer: {
      Text("This only takes effect if both first name and last name are provided.")
    }
  }

  private var privacySection: some View {
    Section {
      Toggle("Private Profile", isOn: $viewModel.isPrivateProfile)
        .onChange(of: [viewModel.isPrivateProfile].publisher.first()) { _ in
          viewModel.updatePrivacySettings(onUpdate: {
            profileManager.refresh()
          })
        }
    } header: {
      Text("Privacy")
    } footer: {
      Text("Private profile hides check-ins and profile page from everyone else but your friends")
    }
    .headerProminence(.increased)
  }
}
