import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct AdminTab: View {
    @Environment(TabManager.self) private var tabManager
    @Environment(Router.self) private var router

    var body: some View {
        AdminScreen()
            .onChange(of: tabManager.resetNavigationOnTab) { _, tab in
                if tab == .admin {
                    router.reset()
                }
            }
    }
}
