import SwiftUI

@MainActor
struct LayoutSelector: View {
    var body: some View {
        #if !os(watchOS)
            switch UIDevice.current.userInterfaceIdiom {
            case .pad, .mac, .vision:
                SideBarView()
            case .phone:
                TabsView()
            default:
                EmptyView()
            }
        #else
            Text("Hello world!")
        #endif
    }
}
