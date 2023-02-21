import os
import SwiftUI

struct AuthenticationScreenView: View {
  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @EnvironmentObject private var toastManager: ToastManager
  @StateObject private var viewModel: ViewModel
  @FocusState private var focusedField: Field?

  init(_ client: Client, scene: Scene) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, scene: scene))
  }

  var body: some View {
    VStack(spacing: viewModel.scene == .signUp ? 4 : 20) {
      projectLogo
      if viewModel.scene == .signUp {
        UsernameTextFieldView(username: $viewModel.username, focusedField: _focusedField)
      }
      if !(viewModel.scene == .resetPassword || viewModel.scene == .accountDeleted) {
        EmailTextFieldView(email: $viewModel.email, focusedField: _focusedField)
      }
      if viewModel.scene == .signIn || viewModel.scene == .signUp || viewModel.scene == .resetPassword {
        PasswordTextFieldView(password: $viewModel.password, focusedField: _focusedField)
      }
      if viewModel.scene == .resetPassword {
        PasswordTextFieldView(password: $viewModel.passwordConfirmation, focusedField: _focusedField)
      }

      if viewModel.scene == .accountDeleted {
        accountDeletion
      }
      actions
    }
    .padding(40)
    .task {
      splashScreenManager.dismiss()
    }
  }

  private var accountDeletion: some View {
    VStack {
      HStack {
        Spacer()
        VStack(spacing: 12) {
          Image(systemName: "trash.circle")
            .resizable()
            .scaledToFit()
            .frame(width: 48, height: 48)
          Text("Account Deleted")
            .font(.title)
        }
        Spacer()
      }
      Spacer()
    }
  }

  private var projectLogo: some View {
    VStack(alignment: .center, spacing: 12) {
      Spacer()
      AppLogoView()
      AppNameView()
      Spacer()
    }
    .accessibilityAddTraits(.isButton)
    .onTapGesture {
      self.focusedField = nil
    }
  }

  private var actions: some View {
    VStack(spacing: 12) {
      Button(action: { viewModel.primaryActionTapped(onSuccess: { message in
        toastManager.toggle(.success(message))
      }, onFailure: { message in
        toastManager.toggle(.error(message))
      }) }) {
        HStack(spacing: 8) {
          if viewModel.isLoading {
            ProgressView()
          }
          Text(viewModel.scene.primaryLabel).bold()
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 6, style: .continuous)
        )
      }
      .disabled(viewModel.isLoading || (viewModel.scene == .resetPassword && !viewModel.isValidNewPassword))

      if viewModel.scene == .forgotPassword {
        HStack {
          Button("Go back to sign in") {
            viewModel.setScene(.signIn)
          }
          Spacer()
        }
      }

      if viewModel.scene == .signIn || viewModel.scene == .signUp {
        Button(
          viewModel.scene == .signIn
            ? "Don't have an account? Sign up"
            : "Do you have an account? Sign in"
        ) {
          viewModel.setScene(viewModel.scene == .signIn ? .signUp : .signIn)
        }
      }

      if viewModel.scene == .signIn {
        Button("Sign in with magic link") {
          viewModel.setScene(.magicLink)
        }
      }

      if viewModel.scene == .signIn {
        Button("Forgot your password?") {
          viewModel.setScene(.forgotPassword)
        }
      }

      if viewModel.scene == .magicLink {
        Button("Sign in with password") {
          viewModel.setScene(.signIn)
        }
      }
    }
  }
}
