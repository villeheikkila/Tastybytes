import EnvironmentModels
import Models
import Repositories
import SwiftUI

@MainActor
struct ProfileTab: View {
    @Environment(Router.self) private var router
    @Environment(TabManager.self) private var tabManager
    @State private var scrollToTop = 0

    var body: some View {
        CurrentProfileScreen(scrollToTop: $scrollToTop)
            .onChange(of: tabManager.resetNavigationOnTab) { _, tab in
                if  tab == .profile {
                    if router.path.isEmpty {
                        scrollToTop += 1
                    } else {
                        router.reset()
                    }
                }
            }
    }
}
