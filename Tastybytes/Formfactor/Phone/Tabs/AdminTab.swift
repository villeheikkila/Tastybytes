import EnvironmentModels
import Models
import SwiftUI

struct AdminTab: View {
    @Environment(Router.self) private var router
    @Environment(TabManager.self) private var tabManager

    var body: some View {
        AdminScreen()
            .onChange(of: tabManager.resetNavigationOnTab) { _, tab in
                if tab == .admin {
                    router.reset()
                }
            }
    }
}
