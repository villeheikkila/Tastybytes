import AlertToast
import GoTrue
import PhotosUI
import SwiftUI

struct SettingsView: View {
    @StateObject private var model = SettingsViewModel()
    @State private var showingImagePicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showDeleteConfirmation = false

    func ImageWithDefault() -> Image {
        guard let image = model.avatarImage else {
            return Image(systemName: "person.fill")
        }
        return Image(uiImage: image)
    }

    var body: some View {
        Form {
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
                model.uploadAvatar(newAvatar: newValue)
            }

            Section {
                TextField("Username", text: $model.username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                TextField("First Name", text: $model.firstName)
                TextField("Last Name", text: $model.lastName)

                if model.profileHasChanged() {
                    Button("Update", action: { model.updateProfile() })
                }
            } header: {
                Text("Profile")
            } footer: {
                Text("These values are used in your personal page and can be seen by other users.")
            }.headerProminence(.increased)
            
            Section {
                Toggle("Use name instead of username", isOn: $model.showFullName)
                    .onChange(of: [self.model.showFullName].publisher.first()) { _ in
                        model.updateDisplaySettings()
               }
            }

            Section {
                TextField("Email", text: $model.email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                if model.emailHasChanged() {
                    Button("Send Verification Link", action: { model.sendEmailVerificationLink() })
                }

            } header: {
                Text("Account")
            } footer: {
                Text("Email is only used for login and is not shown for other users.")
            }.headerProminence(.increased)
            
            Section {
                Button("Log Out", action: { model.logOut() })
            }

            Section {
                Button("Export", action: { model.exportData() })
                Button("Delete Account", role: .destructive, action: {
                    showDeleteConfirmation = true
                })
                .confirmationDialog(
                    "Are you sure you want to permanently delete your account? All data will be lost.",
                    isPresented: $showDeleteConfirmation
                ) {
                    Button("Delete Account", role: .destructive, action: { model.deleteCurrentAccount() })
                }
            }
        }.task {
            model.getInitialValues()
        }
        .toast(isPresenting: $model.showToast, duration: 1, tapToDismiss: true) {
            switch model.toast {
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
        .fileExporter(isPresented: $model.showingExporter,
                      document: model.csvExport,
                      contentType: UTType.commaSeparatedText,
                      defaultFilename: "tasty_export.csv") { result in
            switch result {
            case .success(_):
                model.showToast(type: .exported)
            case .failure(_):
                model.showToast(type: .exportError)
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

    @MainActor class SettingsViewModel: ObservableObject {
        // Profile values
        @Published var username = ""
        @Published var firstName = ""
        @Published var lastName = ""
        @Published var avatarImage: UIImage?
        @Published var showFullName: Bool = false

        // User values
        @Published var email = ""

        @Published var csvExport: CSVFile?

        @Published var showingExporter = false

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
            self.toast = type
            self.showToast = true
        }

        func getInitialValues() {
            Task {
                let user = repository.auth.getCurrentUser()
                let profile = try await repository.profile.getById(id: repository.auth.getCurrentUserId())
                print(profile)
                if let url = profile.getAvatarURL() {
                    getData(from: url) { data, _, error in
                        guard let data = data, error == nil else { return }
                        DispatchQueue.main.async {
                            self.avatarImage = UIImage(data: data)
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.profile = profile
                    self.user = user

                    self.username = profile.username
                    self.lastName = profile.lastName ?? ""
                    self.firstName = profile.firstName ?? ""
                    self.showFullName = profile.nameDisplay == Profile.NameDisplay.fullName
                    self.email = user.email ?? ""
                }
            }
        }

        func updateProfile() {
            let update = ProfileUpdate(
                username: username,
                firstName: firstName,
                lastName: lastName
            )

            Task {
                try await repository.profile.update(id: repository.auth.getCurrentUserId(),
                                                                    update: update)
                self.toast = Toast.profileUpdated
                self.showToast = true
            }
        }
        
        func updateDisplaySettings() {
            let update = ProfileUpdate(
                showFullName: showFullName
            )

            Task {
                try await repository.profile.update(id: repository.auth.getCurrentUserId(),
                                                                    update: update)
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
