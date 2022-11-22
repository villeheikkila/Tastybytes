import GoTrue
import PhotosUI
import SwiftUI

struct ProfileSettingsScreenView: View {
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var toastManager: ToastManager
    @Environment(\.colorScheme) var initialColorScheme

    var body: some View {
        Form {
            profileSection
            profileDisplaySettings
            emailSection
        }
        .navigationTitle("Profile")
        .task {
            viewModel.getInitialValues(profile: profileManager.get())
        }
    }

    var profileSection: some View {
        Section {
            TextField("Username", text: $viewModel.username)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            TextField("First Name", text: $viewModel.firstName)
            TextField("Last Name", text: $viewModel.lastName)

            if viewModel.profileHasChanged() {
                Button("Update", action: { viewModel.updateProfile(onSuccess: {
                    toastManager.toggle(.success("Profile updated!"))
                }) })
            }
        } header: {
            Text("Profile")
        } footer: {
            Text("These values are used in your personal page and can be seen by other users.")
        }
        .headerProminence(.increased)
    }

    var profileDisplaySettings: some View {
        Section {
            Toggle("Use Name Instead of Username", isOn: $viewModel.showFullName)
                .onChange(of: [self.viewModel.showFullName].publisher.first()) { _ in
                    viewModel.updateDisplaySettings()
                }
        } footer: {
            Text("This only takes effect if both first name and last name are provided.")
        }
    }

    var emailSection: some View {
        Section {
            TextField("Email", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            if viewModel.emailHasChanged() {
                Button("Send Verification Link", action: { viewModel.sendEmailVerificationLink() })
            }

        } header: {
            Text("Account")
        } footer: {
            Text("Email is only used for login and is not shown for other users.")
        }
        .headerProminence(.increased)
    }
}

extension ProfileSettingsScreenView {
    @MainActor class ViewModel: ObservableObject {
        @Published var selectedItem: PhotosPickerItem? = nil
        @Published var username = ""
        @Published var firstName = ""
        @Published var lastName = ""
        @Published var showFullName = false
        @Published var email = ""

        var profile: Profile.Extended?
        var user: User?

        func profileHasChanged() -> Bool {
            return ![
                username == profile?.username,
                firstName == profile?.firstName,
                lastName == profile?.lastName,
            ].allSatisfy({ $0 })
        }

        func emailHasChanged() -> Bool {
            return email != user?.email
        }

        func getInitialValues(profile: Profile.Extended) {
            DispatchQueue.main.async {
                self.updateFormValues(profile: profile)
                self.user = supabaseClient.auth.session?.user
                self.email = supabaseClient.auth.session?.user.email ?? ""
            }
        }

        func updateFormValues(profile: Profile.Extended) {
            self.profile = profile
            username = profile.username
            lastName = profile.lastName ?? ""
            firstName = profile.firstName ?? ""
            showFullName = profile.nameDisplay == Profile.NameDisplay.fullName
        }

        func updateProfile(onSuccess: @escaping () -> Void) {
            let update = Profile.UpdateRequest(
                username: username,
                firstName: firstName,
                lastName: lastName
            )

            Task {
                switch await repository.profile.update(id: repository.auth.getCurrentUserId(),
                                                       update: update) {
                case let .success(profile):
                    await MainActor.run {
                        self.updateFormValues(profile: profile)
                        onSuccess()
                    }

                case let .failure(error):
                    print(error)
                }
            }
        }

        func updateDisplaySettings() {
            let update = Profile.UpdateRequest(
                showFullName: showFullName
            )

            Task {
                _ = await repository.profile.update(id: repository.auth.getCurrentUserId(),
                                                    update: update)
            }
        }

        // TODO: Do not log out on email change
        func sendEmailVerificationLink() {
            Task {
                _ = await repository.auth.sendEmailVerification(email: email)
            }
        }
    }
}
