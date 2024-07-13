import Components
import EnvironmentModels
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct ProfileHeaderAvatarSection: View {
    private let logger = Logger(category: "ProfileHeaderAvatarSection")
    @Environment(Router.self) private var router
    @Environment(Repository.self) private var repository
    @Binding var showPicker: Bool
    @Binding var profile: Profile

    let isCurrentUser: Bool
    let showInFull: Bool
    let profileSummary: ProfileSummary?

    var body: some View {
        HStack(alignment: .center) {
            if showInFull {
                Spacer()
                CheckInStatisticView(title: "profile.summary.total", subtitle: .init(stringLiteral: profileSummary?.totalCheckIns.formatted() ?? "0")) {
                    router.open(.screen(.profileProducts(profile)))
                }
            }
            Spacer()
            VStack(alignment: .center) {
                Avatar(profile: profile)
                    .avatarSize(.custom(90))
                    .overlay(alignment: .bottomTrailing) {
                        if isCurrentUser {
                            Button(action: {
                                showPicker = true
                            }, label: {
                                Label("profile.avatar.actions.change", systemImage: "pencil.circle.fill")
                                    .labelStyle(.iconOnly)
                                    .symbolRenderingMode(.multicolor)
                                    .foregroundStyle(.thinMaterial)
                                    .font(.system(size: 24))
                            })
                        }
                    }
            }
            Spacer()
            if showInFull {
                CheckInStatisticView(title: "profile.summary.unique", subtitle: .init(stringLiteral: profileSummary?.uniqueCheckIns.formatted() ?? "0")) {
                    router.open(.screen(.profileProducts(profile)))
                }
                Spacer()
            }
        }
        .contextMenu {
            if let imageEntity = profile.avatars.first, isCurrentUser {
                AsyncButton("profile.avatar.delete.label", systemImage: "trash", role: .destructive) {
                    await deleteAvatar(entity: imageEntity)
                }
            }
        }
    }

    func deleteAvatar(entity: ImageEntity) async {
        do {
            try await repository.imageEntity.delete(from: .avatars, entity: entity)
            withAnimation {
                profile = profile.copyWith(avatars: profile.avatars.removing(entity))
            }
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }
}
