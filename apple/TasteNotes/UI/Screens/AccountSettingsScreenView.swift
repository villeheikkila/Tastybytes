import GoTrue
import PhotosUI
import SwiftUI

struct AccountSettingsScreenView: View {
  @StateObject private var viewModel = ViewModel()
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var toastManager: ToastManager

  var body: some View {
    Form {
      emailSection
      updatePassword
      deleteAccount
    }
    .navigationTitle("Account")
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

  private var updatePassword: some View {
    Section {
      HStack {
        Image(systemName: "key")
        SecureField("New Password", text: $viewModel.newPassword)
          .textContentType(.password)
          .autocapitalization(.none)
          .disableAutocorrection(true)
      }
      HStack {
        Image(systemName: "key")
        SecureField("Confirm New Password", text: $viewModel.newPasswordConfirmation)
          .textContentType(.password)
          .autocapitalization(.none)
          .disableAutocorrection(true)
      }

      if viewModel.showPasswordConfirmation {
        Button("Update password", action: { viewModel.updatePassword() })
      }

    } header: {
      Text("Change password")
    } footer: {
      Text("Password must be at least 8 characters")
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

extension AccountSettingsScreenView {
  @MainActor class ViewModel: ObservableObject {
    @Published var csvExport: CSVFile?
    @Published var showingExporter = false
    @Published var showDeleteConfirmation = false
    @Published var showEmailConfirmationButton = false
    @Published var showPasswordConfirmation = false
    @Published var email = "" {
      didSet {
        withAnimation {
          showEmailConfirmationButton = email != initialEmail
        }
      }
    }

    @Published var newPassword = "" {
      didSet {
        passwordCheck()
      }
    }

    @Published var newPasswordConfirmation = "" {
      didSet {
        passwordCheck()
      }
    }

    func passwordCheck() {
      if newPassword == newPasswordConfirmation, newPassword.count >= 8 {
        showPasswordConfirmation = true

      } else {
        showPasswordConfirmation = false
      }
    }

    private var profile: Profile.Extended?
    private var initialEmail: String?

    func getCSVExportName() -> String {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy_MM_dd_HH_mm"
      let date = Date()
      let timestamp = formatter.string(from: date)
      return "\(Config.appName.lowercased())_export-\(timestamp).csv"
    }

    func getInitialValues(profile _: Profile.Extended) {
      Task {
        let user = try await supabaseClient.auth.session.user
        initialEmail = user.email.orEmpty
        self.email = user.email.orEmpty
      }
    }

    func updatePassword() {
      Task {
        _ = await repository.auth.updatePassword(newPassword: newPassword)
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
