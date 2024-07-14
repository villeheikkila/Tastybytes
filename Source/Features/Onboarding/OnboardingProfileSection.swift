import Components
import EnvironmentModels
import Models
import PhotosUI
import SwiftUI

struct OnboardingProfileSection: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var keyboardShowing = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var username = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var usernameIsAvailable = false
    @State private var isLoading = false
    @State private var isUploadingAvatar = false

    private var canProgressToNextStep: Bool {
        username.count >= 3 && usernameIsAvailable && !username.isEmpty && !isLoading
    }

    var body: some View {
        Form {
            avatarSection
            ProfileInfoSettingSectionsView(usernameIsAvailable: $usernameIsAvailable, username: $username, firstName: $firstName, lastName: $lastName, isLoading: $isLoading)
        }
        .safeAreaInset(edge: .bottom) {
            AsyncButton(action: {
                await profileEnvironmentModel.updateProfile(update: .init(username: username, firstName: firstName, lastName: lastName))
                await profileEnvironmentModel.onboardingUpdate()
            }, label: {
                Text("labels.continue")
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
            .foregroundColor(.black)
            .disabled(!usernameIsAvailable || isLoading || username.count <= 3 || isUploadingAvatar)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .listStyle(.plain)
        .navigationTitle("onboarding.profile.title")
    }

    private var avatarSection: some View {
        HStack {
            Spacer()
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Avatar(profile: profileEnvironmentModel.profile)
                    .avatarSize(.custom(140))
                    .overlay(alignment: .bottomTrailing) {
                        PhotosPicker(selection: $selectedItem,
                                     matching: .images,
                                     photoLibrary: .shared())
                        {
                            Image(systemName: "pencil.circle.fill")
                                .accessibilityHidden(true)
                                .symbolRenderingMode(.multicolor)
                                .font(.system(size: 32))
                                .foregroundColor(.black)
                        }
                        .buttonStyle(.borderless)
                    }
            }
            .task(id: selectedItem) {
                guard let selectedItem else { return }
                isUploadingAvatar = true
                guard let data = await selectedItem.getJPEG() else { return }
                await profileEnvironmentModel.uploadAvatar(data: data)
                isUploadingAvatar = false
            }
            Spacer()
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

struct ProfileInfoSettingSectionsView: View {
    enum FocusField {
        case username, firstName, lastName
    }

    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel

    @FocusState var focusedField: FocusField?
    @Binding var usernameIsAvailable: Bool
    @Binding var username: String
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var isLoading: Bool

    var body: some View {
        requiredSection
        optionalSection
    }

    private var requiredSection: some View {
        Section {
            TextField("Pick an unique username", text: $username)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .focused($focusedField, equals: .username)
        } header: {
            Text("settings.profile.username")
        } footer: {
            Text("settings.profile.username.description")
        }
        .headerProminence(.increased)
        .task {
            username = profileEnvironmentModel.username
            firstName = profileEnvironmentModel.firstName ?? ""
            lastName = profileEnvironmentModel.lastName ?? ""
            usernameIsAvailable = await profileEnvironmentModel.checkIfUsernameIsAvailable(username: username)
        }
        .onChange(of: username) {
            usernameIsAvailable = false
            isLoading = true
        }
        .task(id: username, milliseconds: 300) {
            guard username.count >= 3 else { return }
            let isAvailable = await profileEnvironmentModel
                .checkIfUsernameIsAvailable(username: username)
            withAnimation {
                usernameIsAvailable = isAvailable
                isLoading = false
            }
        }
    }

    private var optionalSection: some View {
        Section {
            TextField("settings.profile.firstName", text: $firstName)
                .focused($focusedField, equals: .firstName)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
            TextField("settings.profile.lastName", text: $lastName)
                .focused($focusedField, equals: .lastName)
                .multilineTextAlignment(.leading)
                .foregroundColor(.black)
        } header: {
            Text("Additional information")
        } footer: {
            Text("These values are optional but can help people find your profile")
        }
        .headerProminence(.increased)
    }
}
