import Components
import EnvironmentModels
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
        .onTapGesture {
            if loadedFrom != .checkIn {
                router.navigate(screen: .checkIn(checkIn))
            }
        }
        .accessibilityAddTraits(.isLink)
    }
}
