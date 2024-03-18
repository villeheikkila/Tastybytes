import Components
import Models
import SwiftUI

@MainActor
struct CheckInDateView: View {
    let checkInAt: Date?

    var body: some View {
        Group {
            if let checkInAt {
                Text(checkInAt.formatted(.customRelativetime))
            } else {
                Text("checkIn.legacy.label")
            }
        }
        .font(.caption)
        .bold()
    }
}
