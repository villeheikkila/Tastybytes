import Models
import SwiftUI

struct ProfileOnboarding: View {
    @Environment(ProfileManager.self) private var profileManager
    @Environment(FeedbackManager.self) private var feedbackManager
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

                Image(systemSymbol: .rectangleAndPencilAndEllipsis)
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
                    .onChange(of: username, debounceTime: 0.3) { newValue in
                        guard newValue.count >= 3 else { return }
                        Task {
                            usernameIsAvailable = await profileManager.checkIfUsernameIsAvailable(username: newValue)
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
                    profileManager.showFullName
                }, set: { newValue in
                    profileManager.showFullName = newValue
                    Task { await profileManager.updateDisplaySettings() }
                }))
            }
            .opacity(firstName.isEmpty || lastName.isEmpty ? 0 : 1)
        }
        .modifier(OnboardingContinueButtonModifier(title: "Continue", isDisabled: !canProgressToNextStep, onClick: {
            Task {
                await profileManager.updateProfile(
                    update: Profile.UpdateRequest(username: username, firstName: firstName,
                                                  lastName: lastName),
                    withFeedback: false
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
            username = profileManager.username
            firstName = profileManager.firstName ?? ""
            lastName = profileManager.lastName ?? ""
            usernameIsAvailable = await profileManager.checkIfUsernameIsAvailable(username: username)
        }
    }
}
