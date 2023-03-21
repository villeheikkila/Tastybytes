import os
import SwiftUI

struct AuthenticationScreen: View {
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
        UsernameTextFieldView(username: $viewModel.username)
          .focused($focusedField, equals: .username)
      }
      if [.signIn, .signUp, .resetPassword, .accountDeleted, .magicLink, .forgotPassword].contains(viewModel.scene) {
        EmailTextFieldView(email: $viewModel.email)
          .focused($focusedField, equals: .email)
      }
      if [.signIn, .signUp, .resetPassword].contains(viewModel.scene) {
        PasswordTextFieldView(
          password: $viewModel.password,
          mode: viewModel.scene == .resetPassword ? .newPassword : .password
        )
        .focused($focusedField, equals: .password)
      }
      if viewModel.scene == .resetPassword {
        PasswordTextFieldView(password: $viewModel.passwordConfirmation, mode: .newPassword)
          .focused($focusedField, equals: .resetPassword)
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
            .accessibility(hidden: true)
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
    .contentShape(Rectangle())
    .accessibilityAddTraits(.isButton)
    .onTapGesture {
      focusedField = nil
    }
  }

  private var actions: some View {
    VStack(spacing: 12) {
      Button(action: { viewModel.primaryActionTapped(onSuccess: { message in
        toastManager.toggle(.success(message))
      }, onFailure: { message in
        toastManager.toggle(.error(message))
      }) }, label: {
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
      })
      .disabled(viewModel.isLoading || (viewModel.scene == .resetPassword && !viewModel.isValidNewPassword))

      if viewModel.scene == .forgotPassword {
        HStack {
          Button("Go back to sign in") {
            viewModel.setScene(.signIn)
          }
          Spacer()
        }
      }

      if [.signIn, .signUp].contains(viewModel.scene) {
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
