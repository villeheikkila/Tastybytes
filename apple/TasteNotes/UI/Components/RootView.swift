import GoTrue
import Supabase
import SwiftUI

struct RootView: View {
    @State private var authEvent: AuthChangeEvent?

    var body: some View {
        Group {
            switch authEvent {
            case .signedIn:
                AuthenticatedContentView()
            case nil:
                ProgressView()
            default:
                AuthenticationScreenView()
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
