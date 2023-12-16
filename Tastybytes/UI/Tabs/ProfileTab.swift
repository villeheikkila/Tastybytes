import EnvironmentModels
import Models
import Repositories
import SwiftUI

struct ProfileTab: View {
    @Environment(\.repository) private var repository
    @Environment(Router.self) private var router
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var scrollToTop = 0
    @Binding var resetNavigationOnTab: Tab?

    var body: some View {
        CurrentProfileScreen(scrollToTop: $scrollToTop)
            .onChange(of: $resetNavigationOnTab.wrappedValue) { _, tab in
                if tab == .profile {
                    if router.path.isEmpty {
                        scrollToTop += 1
                    } else {
                        router.reset()
                    }
                }
            }
    }
}
