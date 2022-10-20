import SwiftUI
import GoTrue
import Supabase

private enum UserEnvironmentKey: EnvironmentKey {
    static var defaultValue: User?
}

extension EnvironmentValues {
    public var user: User? {
        get { self[UserEnvironmentKey.self] }
        set { self[UserEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func withUser(_ user: User?) -> some View {
        environment(\.user, user)
    }
}

public struct UserProviderView<RootView: View>: View {
    let supabaseClient: SupabaseClient
    let rootView: () -> RootView

    @State private var user: User?

    public init(
        supabaseClient: SupabaseClient,
        @ViewBuilder rootView: @escaping () -> RootView
    ) {
        self.supabaseClient = supabaseClient
        self.rootView = rootView
    }

    public var body: some View {
        rootView()
            .withUser(user)
            .task {
                let session = supabaseClient.auth.session
                user = session?.user

                for await _ in supabaseClient.auth.authEventChange.values {
                    user = supabaseClient.auth.session?.user
                }
            }
    }
}
