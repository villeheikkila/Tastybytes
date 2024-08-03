import Components
import Models
import SwiftUI

struct CheckInCardFooter: View {
    @Environment(\.checkInLoadedFrom) private var checkInLoadedFrom
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
            .routerLinkDisabled(checkInLoadedFrom == .checkIn)
            ReactionsView(checkIn: checkIn)
        }
    }
}
