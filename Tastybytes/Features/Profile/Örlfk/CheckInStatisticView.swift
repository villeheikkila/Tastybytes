import SwiftUI

struct CheckInStatisticView: View {
    let title: String
    let subtitle: String
    let onTap: () -> Void

    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .bold()
                .textCase(.uppercase)
            Text(subtitle)
                .contentTransition(.numericText())
                .font(.headline)
        }
        .onTapGesture {
            onTap()
        }
        .accessibilityAddTraits(.isButton)
    }
}
