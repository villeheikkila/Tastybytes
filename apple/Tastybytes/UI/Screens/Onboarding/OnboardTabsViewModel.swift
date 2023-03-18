import PhotosUI
import SwiftUI

@MainActor class OnboardingViewModel: ObservableObject {
  private let logger = getLogger(category: "ProfileSettingsTab")
  let client: Client
  @Published var profile: Profile.Extended?
  @Published var selectedItem: PhotosPickerItem?
  @Published var username = ""
  @Published var firstName = ""
  @Published var lastName = ""
  @Published var showFullName = false
  @Published var isPrivateProfile = false
  @Published var avatarFileName: String?

  init(client: Client) {
    self.client = client
  }

  func loadProfile() {
    Task {
      switch await client.profile.getCurrentUser() {
      case let .success(profile):
        self.profile = profile
        username = profile.username
        lastName = profile.lastName.orEmpty
        firstName = profile.firstName.orEmpty
        showFullName = profile.nameDisplay == Profile.NameDisplay.fullName
        isPrivateProfile = profile.isPrivate
        avatarFileName = profile.avatarUrl
      case let .failure(error):
        logger.error("failed to load profile: \(error.localizedDescription)")
      }
    }
  }

  func updateProfile(onSuccess: @escaping () -> Void) {
    let update = Profile.UpdateRequest(
      username: username,
      firstName: firstName,
      lastName: lastName,
      isPrivate: isPrivateProfile,
      showFullName: showFullName,
      isOnboarded: true
    )

    Task {
      switch await client.profile.update(
        update: update
      ) {
      case .success:
        onSuccess()
      case let .failure(error):
        logger.warning("failed to update profile: \(error.localizedDescription)")
      }
    }
  }

  func uploadAvatar(userId: UUID, newAvatar: PhotosPickerItem?) {
    Task {
      guard let data = await newAvatar?.getJPEG() else { return }
      switch await client.profile.uploadAvatar(userId: userId, data: data) {
      case let .success(fileName):
        self.avatarFileName = fileName
      case let .failure(error):
        logger
          .error(
            "uplodaing avatar for \(userId) failed: \(error.localizedDescription)"
          )
      }
    }
  }
}
