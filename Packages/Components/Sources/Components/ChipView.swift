import SwiftUI

@MainActor
public struct ChipView: View {
    public let title: String

    public var body: some View {
        HStack {
            Text(title).font(.caption2).bold()
        }
        .padding(2)
        .foregroundColor(.white)
        #if !os(watchOS)
            .background(Color(.systemBlue))
        #endif
            .cornerRadius(5)
    }
}
