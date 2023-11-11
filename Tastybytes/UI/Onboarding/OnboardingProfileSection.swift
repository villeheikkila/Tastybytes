import EnvironmentModels
import Models
import SwiftUI

struct OnboardingProfileSection: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @FocusState var focusedField: OnboardField?
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
            HStack {
                Spacer()
                Image(systemName: "rectangle.and.pencil.and.ellipsis")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                Spacer()
            }.listRowSeparator(.hidden)

            Text("Fill in your profile")
                .font(.largeTitle)
                .fontWeight(.semibold)

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
            } footer: {
                Text("These values are shown in your profile page and can be seen by other users.")
            }
            .headerProminence(.increased)
            .onTapGesture {
                focusedField = nil
            }

            Section {
                Toggle("Use your full name instead of username", isOn: .init(get: {
                    profileEnvironmentModel.showFullName
                }, set: { newValue in
                    profileEnvironmentModel.showFullName = newValue
                    Task { await profileEnvironmentModel.updateDisplaySettings() }
                }))
            }
            .opacity(firstName.isEmpty || lastName.isEmpty ? 0 : 1)

            Spacer()
            Button(action: {
                onContinue()
            }, label: {
                Text("Skip")
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
