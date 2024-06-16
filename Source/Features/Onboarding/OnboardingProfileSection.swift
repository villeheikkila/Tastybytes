import Components
import EnvironmentModels
import Models
import PhotosUI
import SwiftUI

@MainActor
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

    let onContinue: () -> Void

    var userNameIsValid: Bool {
        username.count >= 3
    }

    var canProgressToNextStep: Bool {
        userNameIsValid && usernameIsAvailable && !username.isEmpty && !isLoading
    }

    let color = Color(red: 215.0 / 255.0, green: 137.0 / 255.0, blue: 185.0 / 255.0)

    var body: some View {
        Form {
            titleSection
            avatarSection
            profileSection
        }
        .safeAreaInset(edge: .bottom) {
            if focusedField == nil {
                Button(action: {
                    onContinue()
                }, label: {
                    Text("labels.continue")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 60)
                        .foregroundColor(.white)
                        .font(.headline)
                        .background(color)
                        .cornerRadius(15)
                })
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .background(
            AppGradient(color: color),
            alignment: .bottom
        )
        .ignoresSafeArea(edges: .bottom)
        .listStyle(.plain)
        .defaultScrollContentBackground()
        .scrollDisabled(true)
        .simultaneousGesture(DragGesture())
        .accessibility(hidden: true)
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

    private var titleSection: some View {
        Text("onboarding.profile.title")
            .font(.largeTitle)
            .fontWeight(.semibold)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
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
                                .foregroundColor(color)
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

    private var profileSection: some View {
        Section {
            LabeledTextField(title: "settings.profile.username", text: $username)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .focused($focusedField, equals: .username)
            LabeledTextField(title: "settings.profile.firstName", text: $firstName)
                .focused($focusedField, equals: .firstName)
            LabeledTextField(title: "settings.profile.lastName", text: $lastName)
                .focused($focusedField, equals: .lastName)
        }
    }
}
