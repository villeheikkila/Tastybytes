import SwiftUI

struct LayoutSelector: View {
    var body: some View {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad, .mac, .vision:
            SideBarView()
        case .phone:
            TabsView()
        default:
            EmptyView()
        }
    }
}
