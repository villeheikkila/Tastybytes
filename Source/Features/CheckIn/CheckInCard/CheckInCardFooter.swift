import Components
import Models
import SwiftUI

struct CheckInCardFooter: View {
    @Environment(Router.self) private var router

    let checkIn: CheckIn
    let loadedFrom: CheckInCard.LoadedFrom

    var body: some View {
        HStack {
            HStack {
                if let checkInAt = checkIn.checkInAt {
                    Text(checkInAt.customFormat(.relativeTime))
                        .font(.caption)
                        .bold()
                } else {
                    Text("check-in.legacy.label")
                        .font(.caption)
                        .bold()
                }
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
