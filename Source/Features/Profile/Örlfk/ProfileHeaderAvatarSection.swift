import Components
import EnvironmentModels
import Models
import OSLog
import PhotosUI
import SwiftUI

struct ProfileHeaderAvatarSection: View {
    private let logger = Logger(category: "ProfileHeaderAvatarSection")
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(Router.self) private var router
    @Environment(\.repository) private var repository
    @State private var selectedItem: PhotosPickerItem?
    @Binding var profile: Profile

    let isCurrentUser: Bool
    let showInFull: Bool
    let profileSummary: ProfileSummary?

    var body: some View {
        HStack(alignment: .center) {
            if showInFull {
                Spacer()
                CheckInStatisticView(title: "Check-ins", subtitle: String(profileSummary?.totalCheckIns ?? 0)) {
                    router.navigate(screen: .profileProducts(profile))
                }
            }
            Spacer()
            VStack(alignment: .center) {
                AvatarView(avatarUrl: profile.avatarUrl, size: 90, id: profile.id)
                    .overlay(alignment: .bottomTrailing) {
                        if isCurrentUser {
                            PhotosPicker(selection: $selectedItem,
                                         matching: .images,
                                         photoLibrary: .shared())
                            {
                                Image(systemName: "pencil.circle.fill")
                                    .accessibilityHidden(true)
                                    .symbolRenderingMode(.multicolor)
                                    .font(.system(size: 24))
                                    .foregroundColor(.accentColor)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
            }
            .onChange(of: selectedItem) { _, newValue in
                Task { await uploadAvatar(userId: profileEnvironmentModel.id, newAvatar: newValue) }
            }
            Spacer()
            if showInFull {
                CheckInStatisticView(title: "Unique", subtitle: String(profileSummary?.uniqueCheckIns ?? 0)) {
                    router.navigate(screen: .profileProducts(profile))
                }
                Spacer()
            }
        }
        .contextMenu {
            ProfileShareLinkView(profile: profile)
        }
    }

    func uploadAvatar(userId: UUID, newAvatar: PhotosPickerItem?) async {
        guard let data = await newAvatar?.getJPEG() else { return }
        switch await repository.profile.uploadAvatar(userId: userId, data: data) {
        case let .success(avatarFile):
            profile = Profile(
                id: profile.id,
                preferredName: profile.preferredName,
                isPrivate: profile.isPrivate,
                avatarFile: avatarFile,
                joinedAt: profile.joinedAt
            )
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("uplodaing avatar for \(userId) failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
