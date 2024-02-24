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
        .background(Color(.systemBlue))
        .cornerRadius(5)
    }
}
