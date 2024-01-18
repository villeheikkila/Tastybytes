import Components
import Models
import Repositories
import SwiftUI

struct CheckInCardContainer<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 4) {
            content()
        }
        .padding(.vertical, 10)
        .background(colorScheme == .dark ? .thinMaterial : .ultraThin, in: RoundedRectangle(cornerRadius: 8))
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 2, y: 2)
    }
}
