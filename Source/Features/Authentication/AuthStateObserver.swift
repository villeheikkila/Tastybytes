
import Models
import OSLog
import Repositories
import SwiftUI

struct AuthStateObserver<Authenticated: View>: View {
    private let logger = Logger(category: "AuthStateObserver")
    @Environment(ProfileModel.self) private var profileModel
    @ViewBuilder let authenticated: () -> Authenticated

    var body: some View {
        VStack {
            switch profileModel.authState {
            case .authenticated:
                authenticated()
            case .unauthenticated:
                AuthenticationScreen()
            case .none:
                EmptyView()
            }
        }
    }
}
