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

    func getInitialValues(profile: Profile.Extended) async {
      updateFormValues(profile: profile)
    }

    func updateFormValues(profile: Profile.Extended) {
      self.profile = profile
      username = profile.username
      lastName = profile.lastName.orEmpty
      firstName = profile.firstName.orEmpty
      showFullName = profile.nameDisplay == Profile.NameDisplay.fullName
      isPrivateProfile = profile.isPrivate
    }

    func updateProfile(onSuccess: @escaping () async -> Void, onFailure: @escaping (_ error: Error) -> Void) async {
      let update = Profile.UpdateRequest(
        username: username,
        firstName: firstName,
        lastName: lastName
      )

      switch await client.profile.update(
        update: update
      ) {
      case let .success(profile):
        updateFormValues(profile: profile)
        await onSuccess()
      case let .failure(error):
        logger.error("failed to update profile: \(error.localizedDescription)")
        onFailure(error)
      }
    }

    func updatePrivacySettings(onUpdate: @escaping () async -> Void) async {
      let update = Profile.UpdateRequest(isPrivate: isPrivateProfile)
      switch await client.profile.update(
        update: update
      ) {
      case .success:
        await onUpdate()
      case let .failure(error):
        logger.error("failed to update settings: \(error.localizedDescription)")
      }
    }

    func updateDisplaySettings(onUpdate: @escaping () async -> Void) async {
      let update = Profile.UpdateRequest(
        showFullName: showFullName
      )
      switch await client.profile.update(
        update: update
      ) {
      case .success:
        await onUpdate()
      case let .failure(error):
        logger.error("failed to update profile: \(error.localizedDescription)")
      }
    }
  }
}
