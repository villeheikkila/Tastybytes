import Components
import EnvironmentModels
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct ProfileHeaderAvatarSection: View {
    private let logger = Logger(category: "ProfileHeaderAvatarSection")
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(Router.self) private var router
    @Environment(Repository.self) private var repository
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
                Avatar(profile: profile, size: 90)
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
        .onChange(of: selectedItem) { _, newValue in
            Task {
                guard let data = await newValue?.getJPEG() else { return }
                await uploadAvatar(userId: profileEnvironmentModel.id, data: data)
            }
        }
    }

    func uploadAvatar(userId: UUID, data: Data) async {
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
