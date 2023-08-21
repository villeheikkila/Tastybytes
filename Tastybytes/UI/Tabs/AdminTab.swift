import EnvironmentModels
import Models
import SwiftUI

struct AdminTab: View {
    @Binding var resetNavigationOnTab: Tab?

    var body: some View {
        RouterWrapper(tab: .admin) { router in
            AdminScreen()
                .onChange(of: $resetNavigationOnTab.wrappedValue) { _, tab in
                    if tab == .admin {
                        router.reset()
                        resetNavigationOnTab = nil
                    }
                }
        }
    }
}
