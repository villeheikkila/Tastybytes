import PhotosUI
import SwiftUI

extension ProfileView {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ProfileView")
    let client: Client
    @Published var profile: Profile
    @Published var profileSummary: ProfileSummary?
    @Published var selectedItem: PhotosPickerItem?

    let isCurrentUser: Bool
    let isShownInFull: Bool

    init(_ client: Client, profile: Profile, isCurrentUser: Bool) {
      self.client = client
      self.profile = profile
      self.isCurrentUser = isCurrentUser
      isShownInFull = isCurrentUser || !profile.isPrivate
    }

    func uploadAvatar(userId: UUID, newAvatar: PhotosPickerItem?) {
      Task {
        guard let data = await newAvatar?.getJPEG() else { return }
        switch await client.profile.uploadAvatar(userId: userId, data: data) {
        case let .success(avatarFile):
          profile = Profile(
            id: profile.id,
            preferredName: profile.preferredName,
            isPrivate: profile.isPrivate,
            avatarFile: avatarFile,
            joinedAt: profile.joinedAt
          )
        case let .failure(error):
          logger.error("uplodaing avatar for \(userId) failed: \(error.localizedDescription)")
        }
      }
    }

    func getSummary() {
      Task {
        switch await client.checkIn.getSummaryByProfileId(id: profile.id) {
        case let .success(summary):
          withAnimation {
            self.profileSummary = summary
          }
        case let .failure(error):
          logger
            .error(
              "fetching profile data for \(self.profile.id) failed: \(error.localizedDescription)"
            )
        }
      }
    }
  }
}
