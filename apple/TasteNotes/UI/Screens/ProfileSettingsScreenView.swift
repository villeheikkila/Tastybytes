import GoTrue
import PhotosUI
import SwiftUI

struct ProfileSettingsScreenView: View {
  @StateObject private var viewModel = ViewModel()
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var toastManager: ToastManager

  var body: some View {
    Form {
      profileSection
      profileDisplaySettings
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
          toastManager.toggle(.success("Profile updated!"))
        }, onFailure: {
          error in toastManager.toggle(.error(error.localizedDescription))
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
        .onChange(of: [self.viewModel.showFullName].publisher.first()) { _ in
          viewModel.updateDisplaySettings()
        }
    } footer: {
      Text("This only takes effect if both first name and last name are provided.")
    }
  }
}

extension ProfileSettingsScreenView {
  @MainActor class ViewModel: ObservableObject {
    @Published var selectedItem: PhotosPickerItem?
    @Published var username = "" {
      didSet {
        withAnimation {
          showProfileUpdateButton = profileHasChanged()
        }
      }
    }

    @Published var firstName = "" {
      didSet {
        withAnimation {
          showProfileUpdateButton = profileHasChanged()
        }
      }
    }

    @Published var lastName = "" {
      didSet {
        withAnimation {
          showProfileUpdateButton = profileHasChanged()
        }
      }
    }

    @Published var showFullName = false
    @Published var showEmailConfirmationButton = false
    @Published var showProfileUpdateButton = false
    private var profile: Profile.Extended?

    func profileHasChanged() -> Bool {
      ![
        username == profile?.username ?? "",
        firstName == profile?.firstName ?? "",
        lastName == profile?.lastName ?? "",
      ].allSatisfy { $0 }
    }

    func getInitialValues(profile: Profile.Extended) {
      Task {
        self.updateFormValues(profile: profile)
      }
    }

    func updateFormValues(profile: Profile.Extended) {
      self.profile = profile
      username = profile.username
      lastName = profile.lastName.orEmpty
      firstName = profile.firstName.orEmpty
      showFullName = profile.nameDisplay == Profile.NameDisplay.fullName
    }

    func updateProfile(onSuccess: @escaping () -> Void, onFailure: @escaping (_ error: Error) -> Void) {
      let update = Profile.UpdateRequest(
        username: username,
        firstName: firstName,
        lastName: lastName
      )

      Task {
        switch await repository.profile.update(
          update: update
        ) {
        case let .success(profile):
          self.updateFormValues(profile: profile)
          onSuccess()
        case let .failure(error):
          onFailure(error)
        }
      }
    }

    func updateDisplaySettings() {
      let update = Profile.UpdateRequest(
        showFullName: showFullName
      )

      Task {
        _ = await repository.profile.update(
          update: update
        )
      }
    }
  }
}
