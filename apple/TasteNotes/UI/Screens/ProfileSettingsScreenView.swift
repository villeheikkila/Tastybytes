import GoTrue
import PhotosUI
import SwiftUI

struct ProfileSettingsScreenView: View {
  @StateObject private var viewModel = ViewModel()
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var toastManager: ToastManager

  var body: some View {
    Form {
      profileSection
      profileDisplaySettings
      emailSection
      deleteAccount
    }
    .navigationTitle("Profile")
    .fileExporter(isPresented: $viewModel.showingExporter,
                  document: viewModel.csvExport,
                  contentType: UTType.commaSeparatedText,
                  defaultFilename: viewModel.getCSVExportName()) { result in
      switch result {
      case .success:
        toastManager.toggle(.success("Data was exported as CSV"))
      case .failure:
        toastManager.toggle(.error("Error occurred while trying to export data"))
      }
    }
    .confirmationDialog(
      "Delete Account Confirmation",
      isPresented: $viewModel.showDeleteConfirmation
    ) {
      Button(
        "Are you sure you want to permanently delete your account? All data will be lost.",
        role: .destructive,
        action: {
          viewModel.deleteCurrentAccount(onError: {
            message in toastManager.toggle(.error(message))
          })
        }
      )
    }
    .task {
      viewModel.getInitialValues(profile: profileManager.get())
    }
  }

  private var profileSection: some View {
    Section {
      TextField("Username", text: $viewModel.username)
        .autocapitalization(.none)
        .disableAutocorrection(true)
      TextField("First Name", text: $viewModel.firstName)
      TextField("Last Name", text: $viewModel.lastName)

      if viewModel.showProfileUpdateButton {
        Button("Update", action: { viewModel.updateProfile(onSuccess: {
          toastManager.toggle(.success("Profile updated!"))
        }, onFailure: {
          error in toastManager.toggle(.error(error.localizedDescription))
        }) })
      }
    } header: {
      Text("Profile")
    } footer: {
      Text("These values are used in your personal page and can be seen by other users.")
    }
    .headerProminence(.increased)
  }

  private var profileDisplaySettings: some View {
    Section {
      Toggle("Use Name Instead of Username", isOn: $viewModel.showFullName)
        .onChange(of: [self.viewModel.showFullName].publisher.first()) { _ in
          viewModel.updateDisplaySettings()
        }
    } footer: {
      Text("This only takes effect if both first name and last name are provided.")
    }
  }

  private var emailSection: some View {
    Section {
      TextField("Email", text: $viewModel.email)
        .keyboardType(.emailAddress)
        .textContentType(.emailAddress)
        .autocapitalization(.none)
        .disableAutocorrection(true)

      if viewModel.showEmailConfirmationButton {
        Button("Send Verification Link", action: { viewModel.sendEmailVerificationLink() })
      }

    } header: {
      Text("Account")
    } footer: {
      Text("Email is only used for login and is not shown for other users.")
    }
    .headerProminence(.increased)
  }

  private var deleteAccount: some View {
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
          if let destructive = UIColor.perform(Selector(("_systemDestructiveTintColor")))?
            .takeUnretainedValue() as? UIColor
          {
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
    @Published var selectedItem: PhotosPickerItem?
    @Published var username = "" {
      didSet {
        withAnimation {
          showProfileUpdateButton = profileHasChanged()
        }
      }
    }

    @Published var firstName = "" {
      didSet {
        withAnimation {
          showProfileUpdateButton = profileHasChanged()
        }
      }
    }

    @Published var lastName = "" {
      didSet {
        withAnimation {
          showProfileUpdateButton = profileHasChanged()
        }
      }
    }

    @Published var showFullName = false
    @Published var email = "" {
      didSet {
        withAnimation {
          showEmailConfirmationButton = email != initialEmail
        }
      }
    }

    @Published var csvExport: CSVFile?
    @Published var showingExporter = false
    @Published var showDeleteConfirmation = false
    @Published var showEmailConfirmationButton = false
    @Published var showProfileUpdateButton = false

    private var profile: Profile.Extended?
    private var initialEmail: String?

    func getCSVExportName() -> String {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy_MM_dd_HH_mm"
      let date = Date()
      let timestamp = formatter.string(from: date)
      return "tastenotes_export-\(timestamp).csv"
    }

    func profileHasChanged() -> Bool {
      ![
        username == profile?.username ?? "",
        firstName == profile?.firstName ?? "",
        lastName == profile?.lastName ?? "",
      ].allSatisfy { $0 }
    }

    func getInitialValues(profile: Profile.Extended) {
      Task {
        let user = try await supabaseClient.auth.session.user

        self.updateFormValues(profile: profile)
        self.initialEmail = user.email
        self.email = user.email ?? ""
      }
    }

    func updateFormValues(profile: Profile.Extended) {
      self.profile = profile
      username = profile.username
      lastName = profile.lastName ?? ""
      firstName = profile.firstName ?? ""
      showFullName = profile.nameDisplay == Profile.NameDisplay.fullName
    }

    func updateProfile(onSuccess: @escaping () -> Void, onFailure: @escaping (_ error: Error) -> Void) {
      let update = Profile.UpdateRequest(
        username: username,
        firstName: firstName,
        lastName: lastName
      )

      Task {
        switch await repository.profile.update(
          update: update
        ) {
        case let .success(profile):
          self.updateFormValues(profile: profile)
          onSuccess()
        case let .failure(error):
          onFailure(error)
        }
      }
    }

    func updateDisplaySettings() {
      let update = Profile.UpdateRequest(
        showFullName: showFullName
      )

      Task {
        _ = await repository.profile.update(
          update: update
        )
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
          self.csvExport = CSVFile(initialText: csvText)
          self.showingExporter = true
        case let .failure(error):
          onError(error.localizedDescription)
        }
      }
    }

    func deleteCurrentAccount(onError: @escaping (_ error: String) -> Void) {
      Task {
        switch await repository.profile.deleteCurrentAccount() {
        case .success:
          _ = await repository.profile.deleteCurrentAccount()
          _ = await repository.auth.logOut()
        case let .failure(error):
          onError(error.localizedDescription)
        }
      }
    }
  }
}
