import Charts
import Components
import Extensions
import Logging
import Models
import PhotosUI
import Repositories
import SwiftUI

struct ProfileTab: View {
    @Environment(Router.self) private var router
    @Environment(CheckInModel.self) private var checkInModel
    @Environment(ProfileModel.self) private var profileModel
    @State private var showAvatarPicker = false
    @State private var selectedAvatarImage: PhotosPickerItem?

    var profile: Profile.Saved {
        profileModel.profile
    }

    var body: some View {
        List {
            Group {
                ProfileHeaderAvatarSection(
                    showAvatarPicker: $showAvatarPicker, profile: profile,
                    isCurrentUser: true,
                    showInFull: true,
                    profileSummary: checkInModel.profileSummary
                )
                RatingChartView(profile: profile, profileSummary: checkInModel.profileSummary)
                ProfileSummarySection(profile: profile, profileSummary: checkInModel.profileSummary)
                ProfileJoinedAtSection(joinedAt: profile.joinedAt)
                ProfileLinksSection(profile: profile, isCurrentUser: true)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .refreshable {
            await checkInModel.refresh()
        }
        .checkInLoadedFrom(.profile(profile))
        .photosPicker(isPresented: $showAvatarPicker, selection: $selectedAvatarImage, matching: .images, photoLibrary: .shared())
        .task(id: selectedAvatarImage) {
            defer { selectedAvatarImage = nil }
            guard let selectedAvatarImage, let data = await selectedAvatarImage.getImageData() else { return }
            guard let image = UIImage(data: data) else { return }
            router.open(.fullScreenCover(.cropImage(image: image, onSubmit: { image in
                guard let image else { return }
                Task {
                    await profileModel.uploadAvatar(image: image)
                }
            })))
        }
        .navigationTitle(profile.preferredName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            RouterLink("nameTag.show.label", systemImage: "qrcode", open: .sheet(.nameTag(onSuccess: { profileId in
                router.open(.screen(.profileById(profileId)))
            })))
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            RouterLink("settings.title", systemImage: "gear", open: .sheet(.settings))
        }
    }
}
