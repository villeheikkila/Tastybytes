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
            Spacer()
                .listRowBackground(Color.clear)
            deleteAccount
        }
        .navigationTitle("Profile")
        .fileExporter(isPresented: $viewModel.showingExporter,
                      document: viewModel.csvExport,
                      contentType: UTType.commaSeparatedText,
                      defaultFilename: "tasty_export.csv") { result in
            switch result {
            case .success:
                toastManager.toggle(.success("Data was exported as CSV"))
            case .failure:
                toastManager.toggle(.error("Error occurred while trying to export data"))
            }
        }
        .confirmationDialog(
            "Are you sure you want to permanently delete your account? All data will be lost.",
            isPresented: $viewModel.showDeleteConfirmation
        ) {
            Button("Delete Account", role: .destructive, action: {
                viewModel.deleteCurrentAccount(onError: {
                    message in toastManager.toggle(.error(message))
                })
            })
        }
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

    var deleteAccount: some View {
        Section {
            Button(action: {
                viewModel.exportData(onError: {
                    message in toastManager.toggle(.error(message))
                })
            }) {
                Label("Export CSV", systemImage: "square.and.arrow.up")
                    .fontWeight(.medium)
            }
            Button(role: .destructive, action: {
                viewModel.showDeleteConfirmation = true
            }) {
                if UIColor.responds(to: Selector(("_systemDestructiveTintColor"))) {
                    if let destructive = UIColor.perform(Selector(("_systemDestructiveTintColor")))?.takeUnretainedValue() as? UIColor {
                        Label("Delete Account", systemImage: "person.crop.circle.badge.minus")
                            .fontWeight(.medium)
                            .foregroundColor(Color(destructive))
                    } else {
                        Text("Delete Account")
                    }
                }
            }
        }
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

        @Published var csvExport: CSVFile?
        @Published var showingExporter = false
        @Published var showDeleteConfirmation = false

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

        func exportData(onError: @escaping (_ error: String) -> Void) {
            Task {
                switch await repository.profile.currentUserExport() {
                case let .success(csvText):
                    await MainActor.run {
                        self.csvExport = CSVFile(initialText: csvText)
                        self.showingExporter = true
                    }
                case let .failure(error):
                    onError(error.localizedDescription)
                }
            }
        }

        func deleteCurrentAccount(onError: @escaping (_ error: String) -> Void) {
            Task {
                switch await repository.profile.deleteCurrentAccount() {
                case .success():
                    _ = await repository.profile.deleteCurrentAccount()
                    _ = await repository.auth.logOut()
                case let .failure(error):
                    onError(error.localizedDescription)
                }
            }
        }
    }
}
