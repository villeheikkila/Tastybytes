import SwiftUI

extension AccountSettingsScreen {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "AccountSettingsScreen")
    let client: Client
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

    private func passwordCheck() {
      showPasswordConfirmation = newPassword == newPasswordConfirmation && newPassword.count >= 8
    }

    private var profile: Profile.Extended?
    private var initialEmail: String?

    init(_ client: Client) {
      self.client = client
    }

    func getCSVExportName() -> String {
      "\(Config.appName.lowercased())_export_\(Date().customFormat(.fileNameSuffix)).csv"
    }

    func getInitialValues(profile _: Profile.Extended) {
      Task {
        switch await client.auth.getUser() {
        case let .success(user):
          initialEmail = user.email.orEmpty
          self.email = user.email.orEmpty
        case let .failure(error):
          logger.error("failed to get current user data: \(error.localizedDescription)")
        }
      }
    }

    func updatePassword() {
      Task {
        _ = await client.auth.updatePassword(newPassword: newPassword)
      }
    }

    func sendEmailVerificationLink() {
      Task {
        _ = await client.auth.sendEmailVerification(email: email)
      }
    }

    func exportData(onError: @escaping (_ error: String) -> Void) {
      Task {
        switch await client.profile.currentUserExport() {
        case let .success(csvText):
          self.csvExport = CSVFile(initialText: csvText)
          self.showingExporter = true
        case let .failure(error):
          logger.error("failed to export check-in csv: \(error.localizedDescription)")
          onError(error.localizedDescription)
        }
      }
    }

    func deleteCurrentAccount(onError: @escaping (_ error: String) -> Void) {
      Task {
        switch await client.profile.deleteCurrentAccount() {
        case .success:
          _ = await client.auth.logOut()
        case let .failure(error):
          logger.error("failed to delete current account: \(error.localizedDescription)")
          onError(error.localizedDescription)
        }
      }
    }
  }
}
