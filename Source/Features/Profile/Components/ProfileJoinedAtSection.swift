import Models
import SwiftUI

struct ProfileJoinedAtSection: View {
    let joinedAt: Date

    var formattedJoinedAt: String {
        joinedAt.formatted(
            .dateTime
                .year()
                .month(.wide)
                .day())
    }

    var body: some View {
        HStack {
            Spacer()
            Text("profile.joinedAt \(formattedJoinedAt)")
                .fontWeight(.medium)
            Spacer()
        }
    }
}
