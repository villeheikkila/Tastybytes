import SwiftUI

extension ProfileSettingsScreen {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ProfileSettingsScreen")
    let client: Client
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
        lastName == profile?.lastName ?? ""
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
        isPrivate: isPrivateProfile
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
