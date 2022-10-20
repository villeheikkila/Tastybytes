import AlertToast
import GoTrue
import PhotosUI
import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = ViewModel()
    @State private var showingImagePicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showDeleteConfirmation = false
    @EnvironmentObject var currentProfile: CurrentProfile
    @Environment(\.colorScheme) var initialColorScheme

    var body: some View {
        Form {
            avatarPicker
            profileSection
            emailSection
            displaySettings
            logOutSection
            accountDeletionSection
        }.task {
            viewModel.getInitialValues(initialColorScheme: initialColorScheme)
        }
        .toast(isPresenting: $viewModel.showToast, duration: 1, tapToDismiss: true) {
            switch viewModel.toast {
            case .profileUpdated:
                return AlertToast(type: .complete(.green), title: "Profile updated!")
            case .exported:
                return AlertToast(type: .complete(.green), title: "Data was exported as CSV")
            case .exportError:
                return AlertToast(type: .error(.red), title: "Error occured while trying to export data")
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
            selection: $selectedItem,
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
        .onChange(of: selectedItem) { newValue in
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
        }.headerProminence(.increased)
    }

    var displaySettings: some View {
        Section {
            Toggle("Use Name Instead of Username", isOn: $viewModel.showFullName)
                .onChange(of: [self.viewModel.showFullName].publisher.first()) { _ in
                    viewModel.updateDisplaySettings()
                }
            Toggle("Use System Color Scheme", isOn: $viewModel.isSystemColor).onChange(of: [self.viewModel.isSystemColor].publisher.first()) { _ in
                viewModel.updateColorScheme({currentProfile.refresh()})
            }
            Toggle("Use Dark Mode", isOn: $viewModel.isDarkMode).onChange(of: [self.viewModel.isDarkMode].publisher.first()) { _ in
                viewModel.updateColorScheme({currentProfile.refresh()})
            }.disabled(viewModel.isSystemColor)
        }
    }

    var logOutSection: some View {
        Section {
            Button("Log Out", action: { viewModel.logOut() })
        }
    }

    var accountDeletionSection: some View {
        Section {
            Button("Export", action: { viewModel.exportData() })
            Button("Delete Account", role: .destructive, action: {
                showDeleteConfirmation = true
            })
            .confirmationDialog(
                "Are you sure you want to permanently delete your account? All data will be lost.",
                isPresented: $showDeleteConfirmation
            ) {
                Button("Delete Account", role: .destructive, action: { viewModel.deleteCurrentAccount() })
            }
        }
        .fileExporter(isPresented: $viewModel.showingExporter,
                       document: viewModel.csvExport,
                       contentType: UTType.commaSeparatedText,
                       defaultFilename: "tasty_export.csv") { result in
            switch result {
            case .success:
                viewModel.showToast(type: .exported)
            case .failure:
                viewModel.showToast(type: .exportError)
            }
        }
    }
}

extension SettingsView {
    enum Toast {
        case profileUpdated
        case exported
        case exportError
    }

    @MainActor class ViewModel: ObservableObject {
        // Profile values
        @Published var username = ""
        @Published var firstName = ""
        @Published var lastName = ""
        @Published var avatarImage: UIImage?
        @Published var showFullName = false
        @Published var isSystemColor = false
        @Published var isDarkMode = false

        // User values
        @Published var email = ""

        @Published var csvExport: CSVFile?

        @Published var showingExporter = false

        @Published var showToast = false
        @Published var toast: Toast?
        var initialColorScheme: ColorScheme? = nil

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
            self.initialColorScheme = initialColorScheme
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

                DispatchQueue.main.async {
                    self.user = user
                    self.email = user?.email ?? ""
                }

                self.updateFormValues(profile: profile)
            }
        }

        func updateFormValues(profile: Profile) {
            DispatchQueue.main.async {
                self.profile = profile
                self.username = profile.username
                self.lastName = profile.lastName ?? ""
                self.firstName = profile.firstName ?? ""
                self.showFullName = profile.nameDisplay == Profile.NameDisplay.fullName
                switch profile.colorScheme {
                case .light:
                    self.isDarkMode = false
                    self.isSystemColor = false
                case .dark:
                    self.isDarkMode = true
                    self.isSystemColor = false
                case .system:
                    self.isDarkMode = self.initialColorScheme == ColorScheme.dark
                    self.isSystemColor = true
                default:
                    self.isDarkMode = self.initialColorScheme == ColorScheme.dark
                    
                }
            }
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

        func updateColorScheme(_ onChange: @escaping () -> Void) {
            if (isSystemColor) {
                self.isDarkMode = initialColorScheme == ColorScheme.dark
            }
            let update = Profile.Update(
                isDarkMode: isDarkMode, isSystemColor: isSystemColor
            )

            Task {
                try await repository.profile.update(id: repository.auth.getCurrentUserId(),
                                                    update: update)
                onChange()
            }
        }

        func exportData() {
            Task {
                let csvText = try await repository.profile.currentUserExport()
                self.csvExport = CSVFile(initialText: csvText)
                self.showingExporter = true
            }
        }

        // TODO: Do not log out on email change
        func sendEmailVerificationLink() {
            Task {
                try await repository.auth.sendEmailVerification(email: email)
            }
        }

        func logOut() {
            Task {
                try await repository.auth.logOut()
            }
        }

        func deleteCurrentAccount() {
            Task {
                do {
                    try await repository.profile.deleteCurrentAccount()
                    try await repository.auth.logOut()
                } catch {
                    print("error \(error)")
                }
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

        func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
            URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
        }
    }
}

struct CSVFile: FileDocument {
    static var readableContentTypes = [UTType.commaSeparatedText]
    static var writableContentTypes = UTType.commaSeparatedText
    var text = ""

    init(initialText: String = "") {
        text = initialText
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
