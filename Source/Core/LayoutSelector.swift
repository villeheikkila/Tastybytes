import SwiftUI

struct LayoutSelector<Sidebar: View, Tab: View>: View {
    @ViewBuilder let sidebar: () -> Sidebar
    @ViewBuilder let tab: () -> Tab

    var body: some View {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad, .mac, .vision:
            sidebar()
        case .phone:
            tab()
        default:
            EmptyView()
        }
    }
}
