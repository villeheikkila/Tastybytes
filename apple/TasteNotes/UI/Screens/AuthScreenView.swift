import AlertToast
import GoTrue
import Supabase
import SwiftUI

public struct AuthScreenView<AuthenticatedContent: View>: View {
    private let authenticatedContent: (Session) -> AuthenticatedContent
    @State private var authEvent: AuthChangeEvent?

    public init(
        @ViewBuilder authenticatedContent: @escaping (Session) -> AuthenticatedContent
    ) {
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
                SignInOrSignUpView()
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
