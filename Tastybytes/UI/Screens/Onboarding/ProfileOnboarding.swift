import EnvironmentModels
import Models
import SwiftUI

struct ProfileOnboarding: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @FocusState var focusedField: OnboardField?
    @State private var username = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var usernameIsAvailable = false

    @State private var isLoading = false
    @Binding var currentTab: OnboardingScreen.Tab

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
        }
        .modifier(OnboardingContinueButtonModifier(title: "Continue", isDisabled: !canProgressToNextStep, onClick: {
            Task {
                await profileEnvironmentModel.updateProfile(
                    update: Profile.UpdateRequest(username: username, firstName: firstName,
                                                  lastName: lastName)
                )
            }
            withAnimation {
                if let next = currentTab.next {
                    currentTab = next
                }
            }
        }))
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
