import Components
import EnvironmentModels
import Models
import PhotosUI
import SwiftUI

struct ProfileSettingsScreen: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var showAvatarPicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var username = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var usernameIsAvailable = false
    @State private var isLoading = false

    private var canUpdateUsername: Bool {
        username.count >= 3 && !isLoading && usernameIsAvailable
    }

    private var canUpdate: Bool {
        canUpdateUsername && profileEnvironmentModel.hasChanged(username: username, firstName: firstName, lastName: lastName)
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    ProfileAvatarPickerView(showAvatarPicker: $showAvatarPicker, profile: profileEnvironmentModel.profile, allowEdit: true)
                        .avatarSize(.custom(120))
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
            ProfileInfoSettingSectionsView(usernameIsAvailable: $usernameIsAvailable, username: $username, firstName: $firstName, lastName: $lastName, isLoading: $isLoading)
            if profileEnvironmentModel.firstName != nil, profileEnvironmentModel.lastName != nil {
                nameVisibilitySection
            }
            Section {
                AsyncButton(
                    "settings.profile.update",
                    action: {
                        await profileEnvironmentModel.updateProfile(update: .init(
                            username: username,
                            firstName: firstName,
                            lastName: lastName
                        ))
                    }
                ).disabled(!canUpdate)
            }
        }
        .navigationTitle("settings.profile.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .photosPicker(isPresented: $showAvatarPicker, selection: $selectedItem, matching: .images, photoLibrary: .shared())
        .task(id: selectedItem) {
            guard let data = await selectedItem?.getJPEG() else { return }
            await profileEnvironmentModel.uploadAvatar(data: data)
        }
    }

    private var nameVisibilitySection: some View {
        Section {
            Toggle("settings.profile.useFullName.label", isOn: .init(get: {
                profileEnvironmentModel.showFullName
            }, set: { newValue in
                profileEnvironmentModel.showFullName = newValue
                Task { await profileEnvironmentModel.updateDisplaySettings() }
            }))
        } footer: {
            Text("settings.profile.useFullName.description")
        }
    }
}

struct ProfileAvatarPickerView: View {
    @Environment(\.avatarSize) private var avatarSize
    @Binding var showAvatarPicker: Bool
    let profile: Profile
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
