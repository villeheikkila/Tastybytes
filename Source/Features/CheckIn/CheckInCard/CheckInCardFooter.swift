import Components
import Models
import SwiftUI

@MainActor
struct CheckInCardFooter: View {
    @Environment(Router.self) private var router

    let checkIn: CheckIn
    let loadedFrom: CheckInCard.LoadedFrom

    var body: some View {
        HStack {
            HStack {
                CheckInDateView(checkInAt: checkIn.checkInAt)
                Spacer()
            }
            .allowsHitTesting(loadedFrom != .checkIn)
            .contentShape(Rectangle())
            .accessibilityAddTraits(.isLink)
            .onTapGesture {
                if loadedFrom != .checkIn {
                    router.navigate(screen: .checkIn(checkIn))
                }
            }
            ReactionsView(checkIn: checkIn)
        }
    }
}
