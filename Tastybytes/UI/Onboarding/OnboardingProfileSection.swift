import Components
import EnvironmentModels
import Models
import PhotosUI
import SwiftUI

struct OnboardingProfileSection: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
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

    var body: some View {
        Form {
            Text("Fill in your profile")
                .font(.largeTitle)
                .fontWeight(.semibold)

            Section {
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
            }

            Section {
                TextField("Username", text: $username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($focusedField, equals: .username)
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
                TextField("First Name (optional)", text: $firstName)
                    .focused($focusedField, equals: .firstName)
                TextField("Last Name (optional)", text: $lastName)
                    .focused($focusedField, equals: .lastName)
            }
            .onTapGesture {
                focusedField = nil
            }

            Spacer()
            Button(action: {
                onContinue()
            }, label: {
                Text("Continue")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 60)
                    .foregroundColor(.blue)
                    .font(.headline)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            })
            .padding([.leading, .trailing], 20)
            .padding(.top, 20)
        }
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
