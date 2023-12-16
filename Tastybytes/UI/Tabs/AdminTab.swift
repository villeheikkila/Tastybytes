import EnvironmentModels
import Models
import SwiftUI

struct AdminTab: View {
    @Environment(Router.self) private var router
    @Binding var resetNavigationOnTab: Tab?

    var body: some View {
        AdminScreen()
            .onChange(of: $resetNavigationOnTab.wrappedValue) { _, tab in
                if tab == .admin {
                    router.reset()
                }
            }
    }
}
