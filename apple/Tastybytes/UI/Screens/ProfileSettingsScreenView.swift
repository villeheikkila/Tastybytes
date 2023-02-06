import GoTrue
import PhotosUI
import SwiftUI

struct ProfileSettingsScreenView: View {
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
        .onChange(of: [self.viewModel.isPrivateProfile].publisher.first()) { _ in
          viewModel.updatePrivacySettings(onUpdate: {
            profileManager.refresh()
          })
        }
    } header: {
      Text("Privacy")
    } footer: {
      Text("When disabled, only your friends can see your check-ins")
    }
  }
}

extension ProfileSettingsScreenView {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ProfileSettingsScreenView")
    let client: Client
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
    @Published var isPrivateProfile = true
    private var profile: Profile.Extended?

    init(_ client: Client) {
      self.client = client
    }

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
      isPrivateProfile = profile.isPrivate
    }

    func updateProfile(onSuccess: @escaping () -> Void, onFailure: @escaping (_ error: Error) -> Void) {
      let update = Profile.UpdateRequest(
        username: username,
        firstName: firstName,
        lastName: lastName
      )

      Task {
        switch await client.profile.update(
          update: update
        ) {
        case let .success(profile):
          self.updateFormValues(profile: profile)
          onSuccess()
        case let .failure(error):
          logger.warning("failed to update profile: \(error.localizedDescription)")
          onFailure(error)
        }
      }
    }

    func updatePrivacySettings(onUpdate: @escaping () -> Void) {
      let update = Profile.UpdateRequest(
        isPrivate: true
      )

      Task {
        switch await client.profile.update(
          update: update
        ) {
        case .success:
          onUpdate()
        case let .failure(error):
          logger.warning("failed to update settings: \(error.localizedDescription)")
        }
      }
    }

    func updateDisplaySettings(onUpdate: @escaping () -> Void) {
      let update = Profile.UpdateRequest(
        showFullName: showFullName
      )
      Task {
        switch await client.profile.update(
          update: update
        ) {
        case .success:
          onUpdate()
        case let .failure(error):
          logger.warning("failed to update profile: \(error.localizedDescription)")
        }
      }
    }
  }
}
