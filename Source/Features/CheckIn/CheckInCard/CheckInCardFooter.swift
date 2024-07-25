import Components
import Models
import SwiftUI

struct CheckInCardFooter: View {
    @Environment(\.checkInCardLoadedFrom) private var checkInCardLoadedFrom
    @Environment(Router.self) private var router

    let checkIn: CheckIn.Joined

    var body: some View {
        HStack {
            RouterLink(open: .screen(.checkIn(checkIn.id))) {
                HStack {
                    CheckInDateView(checkInAt: checkIn.checkInAt)
                    Spacer()
                }
            }
            .routerLinkDisabled(checkInCardLoadedFrom == .checkIn)
            ReactionsView(checkIn: checkIn)
        }
    }
}
