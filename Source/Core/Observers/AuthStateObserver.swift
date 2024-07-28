
import Models
import OSLog
import Repositories
import SwiftUI

struct AuthStateObserver<Authenticated: View>: View {
    private let logger = Logger(category: "AuthStateObserver")
    @Environment(ProfileModel.self) private var profileModel
    @ViewBuilder let authenticated: () -> Authenticated

    var body: some View {
        switch (profileModel.authState, profileModel.isOnboarded) {
        case (.authenticated, true):
            authenticated()
        case (.authenticated, false), (.unauthenticated, false), (.unauthenticated, true):
            RouterProvider(enableRoutingFromURLs: false) {
                OnboardingScreen()
            }
        case (.none, true), (.none, false):
            EmptyView()
        }
    }
}
