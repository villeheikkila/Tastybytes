import Components

import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct ProfileHeaderAvatarSection: View {
    private let logger = Logger(category: "ProfileHeaderAvatarSection")
    @Environment(Router.self) private var router
    @Environment(Repository.self) private var repository
    @Binding var showAvatarPicker: Bool
    @Binding var profile: Profile.Saved

    let isCurrentUser: Bool
    let showInFull: Bool
    let profileSummary: Profile.Summary?

    private let height: Double = 90

    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 0) {
                HStack {
                    Spacer()
                    if showInFull {
                        CheckInStatisticView(title: "profile.summary.total", subtitle: .init(stringLiteral: profileSummary?.totalCheckIns.formatted() ?? "0")) {
                            router.open(.screen(.profileProducts(profile)))
                        }
                    }
                    Spacer()
                }
                .frame(width: geometry.size.width / 3)

                HStack(alignment: .center, spacing: 0) {
                    Spacer()
                    ProfileAvatarPickerView(showAvatarPicker: $showAvatarPicker, profile: profile, allowEdit: isCurrentUser)
                        .avatarSize(.custom(height))
                    Spacer()
                }
                .frame(width: geometry.size.width / 3)

                HStack {
                    Spacer()
                    if showInFull {
                        CheckInStatisticView(title: "profile.summary.unique", subtitle: .init(stringLiteral: profileSummary?.uniqueCheckIns.formatted() ?? "0")) {
                            router.open(.screen(.profileProducts(profile)))
                        }
                    }
                    Spacer()
                }
                .frame(width: geometry.size.width / 3)
            }
        }
        .frame(height: height)
        .fixedSize(horizontal: false, vertical: true)
        .contextMenu {
            if let imageEntity = profile.avatars.first, isCurrentUser {
                AsyncButton("profile.avatar.delete.label", systemImage: "trash", role: .destructive) {
                    await deleteAvatar(entity: imageEntity)
                }
            }
        }
    }

    private func deleteAvatar(entity: ImageEntity.Saved) async {
        do {
            try await repository.imageEntity.delete(from: .avatars, id: entity.id)
            withAnimation {
                profile = profile.copyWith(avatars: profile.avatars.removing(entity))
            }
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }
}
