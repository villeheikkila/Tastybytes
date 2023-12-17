import Models
import SwiftUI

struct ProfileJoinedAtSection: View {
    let joinedAt: Date

    var body: some View {
        HStack {
            Spacer()
            Text("Joined \(joinedAt.customFormat(.date))")
                .fontWeight(.medium)
            Spacer()
        }
    }
}
