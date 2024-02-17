import SwiftUI

struct CheckInStatisticView: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
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
