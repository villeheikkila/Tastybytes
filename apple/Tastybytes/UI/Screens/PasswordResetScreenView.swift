import GoTrue
import PhotosUI
import SwiftUI

struct PasswordResetScreenView: View {
  @StateObject private var viewModel = ViewModel()

  var body: some View {
    NavigationStack {
      Form {
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

        } footer: {
          Text("Password must be at least 8 characters")
        }
      }
      .navigationTitle("Reset Password")
    }
  }
}

extension PasswordResetScreenView {
  @MainActor class ViewModel: ObservableObject {
    @Published var showPasswordConfirmation = false
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

    func updatePassword() {
      Task {
        _ = await repository.auth.updatePassword(newPassword: newPassword)
      }
    }
  }
}
