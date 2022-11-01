import AlertToast
import GoTrue
import PhotosUI
import SwiftUI

struct ProfileSettingsScreenView: View {
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject var currentProfile: CurrentProfile
    @Environment(\.colorScheme) var initialColorScheme

    var body: some View {
        Form {
            avatarPicker
            profileSection
            profileDisplaySettings
            emailSection
        }
        .navigationTitle("Profile")
        .task {
            viewModel.getInitialValues(initialColorScheme: initialColorScheme)
        }
        .toast(isPresenting: $viewModel.showToast, duration: 1, tapToDismiss: true) {
            switch viewModel.toast {
            case .profileUpdated:
                return AlertToast(type: .complete(.green), title: "Profile updated!")
            case .none:
                return AlertToast(type: .error(.red), title: "")
            }
        }
    }

    func ImageWithDefault() -> Image {
        guard let image = viewModel.avatarImage else {
            return Image(systemName: "person.fill")
        }
        return Image(uiImage: image)
    }

    var avatarPicker: some View {
        PhotosPicker(
            selection: $viewModel.selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            ImageWithDefault()
                .resizable()
                .clipShape(Circle())
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120, alignment: .top)
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 4)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowBackground(Color(UIColor.systemGroupedBackground))
        .padding(.top, 0)
        .onChange(of: viewModel.selectedItem) { newValue in
            viewModel.uploadAvatar(newAvatar: newValue)
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
                Button("Update", action: { viewModel.updateProfile() })
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
    enum Toast {
        case profileUpdated
    }

    @MainActor class ViewModel: ObservableObject {
        @Published var selectedItem: PhotosPickerItem? = nil

        // Profile values
        @Published var username = ""
        @Published var firstName = ""
        @Published var lastName = ""
        @Published var avatarImage: UIImage?
        @Published var showFullName = false
        // User values
        @Published var email = ""
        @Published var showToast = false
        @Published var toast: Toast?

        var profile: Profile?
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

        func showToast(type: Toast) {
            toast = type
            showToast = true
        }

        func getInitialValues(initialColorScheme: ColorScheme) {
            Task {
                let user = repository.auth.getCurrentUser()
                let profile = try await repository.profile.getById(id: repository.auth.getCurrentUserId())
                if let url = profile.getAvatarURL() {
                    getData(from: url) { data, _, error in
                        guard let data = data, error == nil else { return }
                        DispatchQueue.main.async {
                            self.avatarImage = UIImage(data: data)
                        }
                    }
                }

                await MainActor.run {
                    self.user = user
                    self.email = user?.email ?? ""
                }

                self.updateFormValues(profile: profile)
            }
        }

        func updateFormValues(profile: Profile) {
            self.profile = profile
            username = profile.username
            lastName = profile.lastName ?? ""
            firstName = profile.firstName ?? ""
            showFullName = profile.nameDisplay == Profile.NameDisplay.fullName
        }

        func updateProfile() {
            let update = Profile.Update(
                username: username,
                firstName: firstName,
                lastName: lastName
            )

            Task {
                let profile = try await repository.profile.update(id: repository.auth.getCurrentUserId(),
                                                                  update: update)

                self.updateFormValues(profile: profile)
                self.toast = Toast.profileUpdated
                self.showToast = true
            }
        }

        func updateDisplaySettings() {
            let update = Profile.Update(
                showFullName: showFullName
            )

            Task {
                try await repository.profile.update(id: repository.auth.getCurrentUserId(),
                                                    update: update)
            }
        }

        // TODO: Do not log out on email change
        func sendEmailVerificationLink() {
            Task {
                try await repository.auth.sendEmailVerification(email: email)
            }
        }

        func uploadAvatar(newAvatar: PhotosPickerItem?) {
            Task {
                if let imageData = try await newAvatar?.loadTransferable(type: Data.self),
                   let image = UIImage(data: imageData),
                   let data = image.jpegData(compressionQuality: 0.5) {
                    try await repository.profile.uploadAvatar(id: repository.auth.getCurrentUserId(), data: data, completion: { result in switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self.avatarImage = image
                        }
                    case let .failure(error):
                        print(error.localizedDescription)
                    }})
                }
            }
        }
    }
}
