import SwiftUI

struct CheckInStatisticView: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Text(title)
                    .font(.caption)
                    .bold()
                    .textCase(.uppercase)
                Text(subtitle)
                    .contentTransition(.numericText())
                    .font(.headline)
            }
        }
        .buttonStyle(.plain)
    }
}
