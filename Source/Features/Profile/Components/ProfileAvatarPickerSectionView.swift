import Components
import EnvironmentModels
import Models
import PhotosUI
import SwiftUI

struct ProfileAvatarPickerSectionView: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var showAvatarPicker = false
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        Section {
            HStack {
                Spacer()
                ProfileAvatarPickerView(showAvatarPicker: $showAvatarPicker, profile: profileEnvironmentModel.profile, allowEdit: true)
                    .avatarSize(.custom(120))
                Spacer()
            }
        }
        .listRowBackground(Color.clear)
        .photosPicker(isPresented: $showAvatarPicker, selection: $selectedItem, matching: .images, photoLibrary: .shared())
        .task(id: selectedItem) {
            guard let data = await selectedItem?.getJPEG() else { return }
            await profileEnvironmentModel.uploadAvatar(data: data)
        }
    }
}

struct ProfileAvatarPickerView: View {
    @Environment(\.avatarSize) private var avatarSize
    @Binding var showAvatarPicker: Bool
    let profile: Profile.Saved
    let allowEdit: Bool

    var body: some View {
        Avatar(profile: profile)
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
