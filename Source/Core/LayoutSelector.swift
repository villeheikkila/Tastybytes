import SwiftUI

struct LayoutSelector: View {
    var body: some View {
        if isPadOrMac() {
            SideBarView()
        } else {
            TabsView()
        }
    }
}
