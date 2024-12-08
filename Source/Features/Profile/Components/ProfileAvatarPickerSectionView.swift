import Components

import Models
import PhotosUI
import SwiftUI

struct ProfileAvatarPickerSectionView: View {
    @Environment(Router.self) private var router
    @Environment(ProfileModel.self) private var profileModel
    @State private var showAvatarPicker = false
    @State private var selectedAvatarImage: PhotosPickerItem?

    var body: some View {
        Section {
            HStack {
                Spacer()
                ProfileAvatarPickerView(showAvatarPicker: $showAvatarPicker, profile: profileModel.profile, allowEdit: true)
                    .avatarSize(.custom(120))
                Spacer()
            }
        }
        .listRowBackground(Color.clear)
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
    }
}

struct ProfileAvatarPickerView: View {
    @Environment(\.avatarSize) private var avatarSize
    @Binding var showAvatarPicker: Bool
    let profile: Profile.Saved
    let allowEdit: Bool

    var body: some View {
        AvatarView(profile: profile)
            .overlay(alignment: .bottomTrailing) {
                if allowEdit {
                    Button(action: {
                        showAvatarPicker = true
                    }, label: {
                        Label("profile.avatar.actions.change", systemImage: "pencil.circle.fill")
                            .labelStyle(.iconOnly)
                            .symbolRenderingMode(.multicolor)
                            .foregroundStyle(.thinMaterial)
                            .font(.system(size: avatarSize.size / 3.75))
                    })
                }
            }
    }
}
