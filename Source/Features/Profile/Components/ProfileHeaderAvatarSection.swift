import Components
import EnvironmentModels
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

@MainActor
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
                CheckInStatisticView(title: "profile.summary.total", subtitle: .init(stringLiteral: profileSummary?.totalCheckIns.formatted() ?? "0")) {
                    router.navigate(screen: .profileProducts(profile))
                }
            }
            Spacer()
            VStack(alignment: .center) {
                Avatar(profile: profile)
                    .avatarSize(.custom(90))
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
                CheckInStatisticView(title: "profile.summary.unique", subtitle: .init(stringLiteral: profileSummary?.uniqueCheckIns.formatted() ?? "0")) {
                    router.navigate(screen: .profileProducts(profile))
                }
                Spacer()
            }
        }
        .contextMenu {
            if let imageEntity = profile.avatars.first, isCurrentUser {
                ProgressButton("profile.avatar.delete.label", systemImage: "trash", role: .destructive) {
                    await deleteAvatar(entity: imageEntity)
                }
            }
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
        case let .success(imageEntity):
            profile = profile.copyWith(avatars: [imageEntity])
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Uploading of a avatar for \(userId) failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteAvatar(entity: ImageEntity) async {
        switch await repository.imageEntity.delete(from: .avatars, entity: entity) {
        case .success:
            withAnimation {
                profile = profile.copyWith(avatars: profile.avatars.removing(entity))
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }
}
