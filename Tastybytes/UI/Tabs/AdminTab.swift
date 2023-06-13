import SwiftUI

struct AdminTab: View {
    @Environment(SplashScreenManager.self) private var splashScreenManager
    @Binding var resetNavigationOnTab: Tab?

    var body: some View {
        RouterWrapper(tab: .admin) { router in
            AdminScreen()
                .task {
                    await splashScreenManager.dismiss()
                }
                .onChange(of: $resetNavigationOnTab.wrappedValue) { _, tab in
                    if tab == .admin {
                        router.reset()
                        resetNavigationOnTab = nil
                    }
                }
        }
    }
}
