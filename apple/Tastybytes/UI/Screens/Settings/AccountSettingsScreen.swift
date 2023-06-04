import PhotosUI
import SwiftUI

struct AccountSettingsScreen: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @State private var showDeleteConfirmation = false
  @State private var showEmailConfirmation = false
  @State private var showPasswordConfirmation = false
  @State private var showAccountDeleteScreen = false
  @State private var email = ""
  @State private var newPassword = "" {
    didSet {
      passwordCheck()
    }
  }

  @State private var newPasswordConfirmation = "" {
    didSet {
      passwordCheck()
    }
  }

  private func passwordCheck() {
    withAnimation {
      showPasswordConfirmation = newPassword == newPasswordConfirmation && newPassword.count >= 8
    }
  }

  var body: some View {
    Form {
      emailSection
      updatePassword
      deleteAccount
    }
    .navigationTitle("Account")
    .fullScreenCover(isPresented: $showAccountDeleteScreen, content: {
      AccountDeletedScreen()
    })
    .transaction { transaction in
      if showAccountDeleteScreen {
        transaction.disablesAnimations = true
      }
    }
    .onChange(of: profileManager.email, perform: { _ in
      withAnimation {
        showEmailConfirmation = email != profileManager.email
      }
    })
    .onAppear {
      email = profileManager.email
    }
    .fileExporter(isPresented: $profileManager.showingExporter,
                  document: profileManager.csvExport,
                  contentType: UTType.commaSeparatedText,
                  defaultFilename: profileManager.getCSVExportName())
    { result in
      switch result {
      case .success:
        feedbackManager.toggle(.success("Data was exported as CSV"))
      case .failure:
        feedbackManager.toggle(.error(.custom("Error occurred while trying to export data")))
      }
    }
    .confirmationDialog(
      "Are you sure you want to permanently delete your account? All data will be lost.",
      isPresented: $showDeleteConfirmation,
      titleVisibility: .visible
    ) {
      ProgressButton(
        "Delete Account",
        role: .destructive,
        action: {
          await profileManager.deleteCurrentAccount(onAccountDeletion: {
            showAccountDeleteScreen = true
          })
        }
      )
    }
  }

  private var updatePassword: some View {
    Section {
      HStack {
        Image(systemSymbol: .key)
          .accessibility(hidden: true)
        SecureField("New Password", text: $newPassword)
          .textContentType(.newPassword)
          .autocapitalization(.none)
          .disableAutocorrection(true)
      }
      HStack {
        Image(systemSymbol: .key)
          .accessibility(hidden: true)
        SecureField("Confirm New Password", text: $newPasswordConfirmation)
          .textContentType(.newPassword)
          .autocapitalization(.none)
          .disableAutocorrection(true)
      }
      if showPasswordConfirmation {
        ProgressButton("Update password", action: { await profileManager.updatePassword(newPassword: newPassword) })
      }
    } header: {
      Text("Change password")
    } footer: {
      Text("Password must be at least 8 characters")
    }
    .headerProminence(.increased)
  }

  private var emailSection: some View {
    Section {
      TextField("Email", text: $email)
        .keyboardType(.emailAddress)
        .textContentType(.emailAddress)
        .autocapitalization(.none)
        .disableAutocorrection(true)

      if showEmailConfirmation {
        ProgressButton("Send Verification Link", action: { await profileManager.sendEmailVerificationLink() })
          .transition(.slide)
      }

    } header: {
      Text("Email")
    } footer: {
      Text("Email is only used for login and is not shown for other users.")
    }
    .headerProminence(.increased)
  }

  private var deleteAccount: some View {
    Section {
      Group {
        ProgressButton(
          "Export CSV",
          systemSymbol: .squareAndArrowUp,
          action: { await profileManager.exportData() }
        )
        Button(
          "Delete Account",
          systemSymbol: .personCropCircleBadgeMinus,
          role: .destructive,
          action: { showDeleteConfirmation = true }
        ).foregroundColor(.red)
      }.fontWeight(.medium)
    }
  }
}
