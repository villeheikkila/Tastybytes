import SwiftUI

extension AccountSettingsScreen {
  @MainActor
  class ViewModel: ObservableObject {
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

    func getInitialValues(profile _: Profile.Extended) async {
      switch await client.auth.getUser() {
      case let .success(user):
        initialEmail = user.email.orEmpty
        email = user.email.orEmpty
      case let .failure(error):
        logger.error("failed to get current user data: \(error.localizedDescription)")
      }
    }

    func updatePassword() async {
      _ = await client.auth.updatePassword(newPassword: newPassword)
    }

    func sendEmailVerificationLink() async {
      _ = await client.auth.sendEmailVerification(email: email)
    }

    func exportData(onError: @escaping (_ error: String) -> Void) async {
      switch await client.profile.currentUserExport() {
      case let .success(csvText):
        csvExport = CSVFile(initialText: csvText)
        showingExporter = true
      case let .failure(error):
        logger.error("failed to export check-in csv: \(error.localizedDescription)")
        onError(error.localizedDescription)
      }
    }

    func deleteCurrentAccount(onError: @escaping (_ error: String) -> Void) async {
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
