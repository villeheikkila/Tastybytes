import Components
import EnvironmentModels
import Models
import PhotosUI
import SwiftUI

enum OnboardField {
    case username, firstName, lastName
}

struct OnboardingProfileSection: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var keyboardShowing = false
    @FocusState var focusedField: OnboardField?
    @State private var selectedItem: PhotosPickerItem?
    @State private var username = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var usernameIsAvailable = false
    @State private var isLoading = false

    var userNameIsValid: Bool {
        username.count >= 3
    }

    var canProgressToNextStep: Bool {
        userNameIsValid && usernameIsAvailable && !username.isEmpty && !isLoading
    }

    var body: some View {
        Form {
            avatarSection
            requiredSection
            optionalSection
        }
        .safeAreaInset(edge: .bottom) {
            ProgressButton(action: {
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
            .disabled(!usernameIsAvailable || isLoading || username.count <= 3)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .listStyle(.plain)
        .navigationTitle("onboarding.profile.title")
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
            .onChange(of: selectedItem) { _, newValue in
                guard let newValue else { return }
                Task {
                    guard let data = await newValue.getJPEG() else { return }
                    await profileEnvironmentModel.uploadAvatar(data: data)
                }
            }
            Spacer()
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private var requiredSection: some View {
        Section("settings.profile.username") {
            TextField("Pick an unique username", text: $username)
                .multilineTextAlignment(.leading)
                .foregroundColor(.secondary)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .focused($focusedField, equals: .username)
        }
        .headerProminence(.increased)
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
