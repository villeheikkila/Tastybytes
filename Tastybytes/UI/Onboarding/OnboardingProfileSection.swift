import Components
import EnvironmentModels
import Models
import PhotosUI
import SwiftUI

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
            Text("Set up your profile")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            HStack {
                Spacer()
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    AvatarView(
                        avatarUrl: profileEnvironmentModel.profile.avatarUrl,
                        size: 140,
                        id: profileEnvironmentModel.id
                    )
                }
                .onChange(of: selectedItem) { _, newValue in
                    guard let newValue else { return }
                    Task { await profileEnvironmentModel.uploadAvatar(newAvatar: newValue) }
                }
                Spacer()
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            Section {
                LabeledTextField(title: "Username", text: $username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($focusedField, equals: .username)
                    .onTapGesture {
                        focusedField = .username
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
                LabeledTextField(title: "First Name (optional)", text: $firstName)
                    .focused($focusedField, equals: .firstName)
                    .onTapGesture {
                        focusedField = .firstName
                    }
                LabeledTextField(title: "Last Name (optional)", text: $lastName)
                    .focused($focusedField, equals: .lastName)
                    .onTapGesture {
                        focusedField = .lastName
                    }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if focusedField == nil {
                Button(action: {
                    onContinue()
                }, label: {
                    Text("Continue")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 60)
                        .foregroundColor(.white)
                        .font(.headline)
                        .background(color)
                        .cornerRadius(15)
                })
                .padding()
                .padding()
            }
        }
        .background(
            AppGradient(color: color),
            alignment: .bottom
        )
        .ignoresSafeArea(edges: .bottom)
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
        .simultaneousGesture(DragGesture())
        .accessibility(hidden: true)
        .task {
            username = profileEnvironmentModel.username
            firstName = profileEnvironmentModel.firstName ?? ""
            lastName = profileEnvironmentModel.lastName ?? ""
            usernameIsAvailable = await profileEnvironmentModel.checkIfUsernameIsAvailable(username: username)
        }
    }
}
