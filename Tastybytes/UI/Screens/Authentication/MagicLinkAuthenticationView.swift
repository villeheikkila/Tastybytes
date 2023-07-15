import OSLog
import SwiftUI

struct MagicLinkAuthenticationView: View {
    private let logger = Logger(category: "MagicLinkAuthenticationView")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackManager.self) private var feedbackManager
    @State private var email = ""
    @State private var isLoading = false

    var body: some View {
        VStack {
            EmailTextFieldView(email: $email)
            ProgressButton(action: { await signUpWithMagicLink() }, actionOptions: Set(), label: {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                    }
                    Text("Send Magic Link").bold()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                )
            })
            .disabled(isLoading)
        }
    }

    func signUpWithMagicLink() async {
        isLoading = true
        switch await repository.auth.sendMagicLink(email: email) {
        case .success:
            feedbackManager.toggle(.success("Magic link sent!"))
        case let .failure(error):
            feedbackManager.toggle(.error(.custom(error.localizedDescription)))
            logger
                .error(
                    "Error occured when trying to log in with magic link. Error: \(error) (\(#file):\(#line))"
                )
        }
        isLoading = false
    }
}
