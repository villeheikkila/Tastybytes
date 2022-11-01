import AlertToast
import GoTrue
import Supabase
import SwiftUI

public struct AuthScreenView<AuthenticatedContent: View>: View {
    private let magicLinkEnabled: Bool
    private let authenticatedContent: (Session) -> AuthenticatedContent
    
    @State private var authEvent: AuthChangeEvent?
    
    public init(
        @ViewBuilder authenticatedContent: @escaping (Session) -> AuthenticatedContent
    ) {
        self.magicLinkEnabled = false
        self.authenticatedContent = authenticatedContent
    }
    
    public var body: some View {
        Group {
            switch (authEvent, supabaseClient.auth.session) {
            case let (.signedIn, session?):
                authenticatedContent(session)
            case (nil, _):
                ProgressView()
            default:
                SignInOrSignUpView(
                    magicLinkEnabled: magicLinkEnabled
                )
            }
        }
        .onOpenURL { url in
            Task { _ = try await supabaseClient.auth.session(from: url) }
        }
        .task {
            for await authEventChange in supabaseClient.auth.authEventChange.values {
                withAnimation {
                    self.authEvent = authEventChange
                }
            }
        }
    }
}

struct SignInOrSignUpView: View {
    enum ResultStatus {
        case idle
        case loading
        case result(Result<Void, Error>)
        
        var isLoading: Bool {
            if case .loading = self {
                return true
            }
            return false
        }
    }
    
    enum Mode {
        case signIn, signUp, magicLink, forgotPassword
    }
    
    enum Toast {
        case confirmationEmailSent
        case error(String)
    }
    
    enum Field {
        case email
        case password
    }
    
    func showToast(type: Toast) {
        self.activeToast = type
        self.showToast = true
    }
    
    
    let magicLinkEnabled: Bool
    
    @State var email = ""
    @State var password = ""
    
    @State var mode: Mode = .signIn
    @State var status = ResultStatus.idle
    
    @State var showToast = false
    @State var activeToast: Toast? = nil
    @FocusState private var focusedField: Field?
    
    
    var body: some View { VStack {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(alignment: .center) {
                Text("tastey").font(.title).fontWeight(.bold)
                
                Image("app-icon")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .padding(.top, 5)
            }.onTapGesture {
                self.focusedField = nil
            }
            
            Spacer()
            
            
            emailTextField
            
            if mode == .signIn || mode == .signUp {
                passwordTextField
            }
            
            VStack(spacing: 12) {
                Button(action: primaryActionTapped) {
                    HStack(spacing: 8) {
                        if status.isLoading {
                            if #available(iOS 14.0, *) {
                                ProgressView()
                            } else {
                                Text("Submitting...").bold()
                            }
                        }
                        
                        Text(primaryButtonText).bold()
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                    )
                }
                .disabled(status.isLoading)
                
                if mode == .forgotPassword {
                    HStack {
                        Button("Go back to sign in") {
                            withAnimation { mode = .signIn }
                        }
                        
                        Spacer()
                    }
                }
                
                if magicLinkEnabled, mode == .signIn {
                    Button("Sign in with magic link") {
                        withAnimation { mode = .magicLink }
                    }
                }
                
                if mode == .signIn || mode == .signUp {
                    Button(
                        mode == .signIn
                        ? "Don't have an account? Sign up"
                        : "Do you have an account? Sign in"
                    ) {
                        withAnimation { mode = mode == .signIn ? .signUp : .signIn }
                    }
                }
                
                if mode == .signIn {
                    Button("Forgot your password?") {
                        withAnimation { mode = .forgotPassword }
                    }
                }
                
                if mode == .magicLink {
                    Button("Sign in with password") {
                        withAnimation { mode = .signIn }
                    }
                }
            }
        }
        .padding(40)
        Spacer()
    }
    .toast(isPresenting: $showToast, duration: 1, tapToDismiss: true) {
        switch activeToast {
        case .confirmationEmailSent:
            return AlertToast(displayMode: .banner(.slide), type: .complete(.green), title: "Confirmation email has been sent!")
        case let .error(error):
            return AlertToast(displayMode: .banner(.slide), type: .error(.red), title: error)
        case .none:
            return AlertToast(type: .error(.red), title: "")
        }
    }
    }
    
    var emailTextField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "envelope")
                TextField("Email address", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .focused($focusedField, equals: .email)
            .padding()
            .padding(5)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.vertical, 5)
        }
    }
    
    var passwordTextField: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "key")
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .focused($focusedField, equals: .password)
            .padding()
            .padding(5)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.vertical, 5)
        }
    }
    
    var primaryButtonText: String {
        switch mode {
        case .signIn: return "Sign in"
        case .signUp: return "Sign up"
        case .magicLink: return "Send magic link"
        case .forgotPassword: return "Send reset password instructions"
        }
    }
    
    private func primaryActionTapped() {
        Task {
            status = .loading
            
            do {
                switch mode {
                case .signIn:
                    _ = try await supabaseClient.auth.signIn(email: email, password: password)
                case .signUp:
                    _ =
                    try await supabaseClient.auth.signUp(email: email, password: password)
                    self.activeToast = Toast.confirmationEmailSent
                    self.showToast = true
                case .magicLink:
                    try await supabaseClient.auth.signIn(email: email)
                case .forgotPassword:
                    try await supabaseClient.auth.resetPasswordForEmail(email)
                }
                status = .result(.success(()))
            } catch {
                showToast(type: Toast.error(error.localizedDescription))
                status = .result(.failure(error))
            }
        }
    }
}
