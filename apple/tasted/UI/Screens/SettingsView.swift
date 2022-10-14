import PhotosUI
import SwiftUI

struct SettingsView: View {
    @StateObject private var model = SettingsViewModel()
    @State private var showingImagePicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showDeleteConfirmation: Bool = false

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
                Button("Update", action: { model.updateProfile() })

            } header: {
                Text("Profile")
            } footer: {
                Text("These values are used in your personal page and can be seen by other users.")
            }.headerProminence(.increased)

            Section {
                TextField("Email", text: $model.email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                if model.email != API.supabase.auth.session?.user.email {
                    Button("Send Verification Link", action: { model.sendEmailVerificationLink() })
                }

            } header: {
                Text("Account")
            } footer: {
                Text("Email is only used for login and is not shown for other users.")
            }.headerProminence(.increased)

            Section {
                Button("Log out", action: { model.logOut() })
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
    }
}

extension SettingsView {
    @MainActor class SettingsViewModel: ObservableObject {
        @Published var username = ""
        @Published var firstName = ""
        @Published var lastName = ""
        @Published var email = ""
        @Published var avatarImage: UIImage?

        func getInitialValues() {
            Task {
                let profile = try await SupabaseProfileRepository().loadProfileById(id: getCurrentUserIdUUID())

                if let url = profile.avatarUrl != nil
                    ? URL(
                        string:
                        "https://dmkvuqooctolvhdsubot.supabase.co/storage/v1/object/public/avatars/\(profile.avatarUrl!)"
                    ) : nil {
                    print(url)
                    getData(from: url) { data, _, error in
                        guard let data = data, error == nil else { return }
                        DispatchQueue.main.async {
                            self.avatarImage = UIImage(data: data)
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.username = profile.username
                    self.lastName = profile.lastName ?? ""
                    self.firstName = profile.firstName ?? ""
                    self.email = API.supabase.auth.session?.user.email ?? ""
                }
            }
        }

        func updateProfile() {
            let update = ProfileUpdate(
                username: username,
                firstName: firstName,
                lastName: lastName)

            Task {
                try await SupabaseProfileRepository().updateProfile(id: getCurrentUserIdUUID(),
                                                                    update: update)
            }
        }

        func exportData() {
            Task {
                let csvText = try await SupabaseProfileRepository().currentUserExport()
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    do {
                        try csvText.write(
                            to: dir.appendingPathComponent("tasted_export.csv"), atomically: false,
                            encoding: .utf8)
                    } catch {
                        print("Error")
                    }
                }
            }
        }

        // TODO: Do not log out on email change
        func sendEmailVerificationLink() {
            Task {
                try? await SupabaseProfileRepository().sendEmailVerification(email: email)
            }
        }

        func logOut() {
            Task {
                try await SupabaseProfileRepository().logOut()
            }
        }

        func deleteCurrentAccount() {
            Task {
                try await SupabaseProfileRepository().deleteCurrentAccount()
                try await SupabaseProfileRepository().logOut()
            }
        }

        func uploadAvatar(newAvatar: PhotosPickerItem?) {
            Task {
                if let imageData = try await newAvatar?.loadTransferable(type: Data.self),
                   let image = UIImage(data: imageData),
                   let data = image.jpegData(compressionQuality: 0.5) {
                    try await SupabaseProfileRepository().uploadAvatar(id: getCurrentUserIdUUID(), data: data, completion: { result in switch result {
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
