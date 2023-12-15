import Components
import Models
import Repositories
import SwiftUI

struct CheckInCardContainer<Content: View>: View {
    @Environment(Router.self) private var router
    @Environment(\.colorScheme) private var colorScheme

    let checkIn: CheckIn
    let loadedFrom: CheckInCard.LoadedFrom
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 4) {
            content()
        }
        .padding(.vertical, 10)
        .background(colorScheme == .dark ? .thinMaterial : .ultraThin)
        .clipped()
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 2, y: 2)
        .allowsHitTesting(loadedFrom != .checkIn)
        .onTapGesture {
            router.navigate(screen: .checkIn(checkIn))
        }
        .accessibilityAddTraits(.isLink)
    }
}
