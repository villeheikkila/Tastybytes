import Components
import Models
import SwiftUI

struct CheckInCardFooter: View {
    @Environment(Router.self) private var router

    let checkIn: CheckIn
    let loadedFrom: CheckInCard.LoadedFrom

    var body: some View {
        HStack {
            RouterLink(open: .screen(.checkIn(checkIn))) {
                HStack {
                    CheckInDateView(checkInAt: checkIn.checkInAt)
                    Spacer()
                }
            }
            .routerLinkDisabled(loadedFrom == .checkIn)
            ReactionsView(checkIn: checkIn)
        }
    }
}
