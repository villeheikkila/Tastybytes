import GoTrue
import PhotosUI
import SwiftUI

struct AccountSettingsScreenView: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var toastManager: ToastManager

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

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
          hapticManager.trigger(of: .notification(.success))
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
    .headerProminence(.increased)
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
      Text("Email")
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
