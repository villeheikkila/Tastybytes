import SwiftUI

struct FormFactorSelector: View {
    var body: some View {
        if isPadOrMac() {
            SideBarView()
        } else {
            TabsView()
        }
    }
}
