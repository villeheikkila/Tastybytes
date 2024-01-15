import Components
import Models
import SwiftUI

struct CheckInCardCheckIn: View {
    @Environment(Router.self) private var router

    let checkIn: CheckIn
    let loadedFrom: CheckInCard.LoadedFrom

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let rating = checkIn.rating {
                HStack {
                    RatingView(rating: rating)
                    Spacer()
                }
            }

            if let review = checkIn.review {
                HStack {
                    Text(review)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Spacer()
                }
            }

            FlavorsView(flavors: checkIn.flavors.map(\.flavor))

            if let purchaseLocation = checkIn.purchaseLocation {
                HStack {
                    Text("Purchased from __\(purchaseLocation.name)__")
                        .accessibilityAddTraits(.isLink)
                        .allowsHitTesting(!loadedFrom.isLoadedFromLocation(purchaseLocation))
                        .onTapGesture {
                            router.navigate(screen: .location(purchaseLocation))
                        }

                    Spacer()
                }
            }
        }
        .contentShape(Rectangle())
        .accessibilityAddTraits(.isLink)
        .allowsHitTesting(loadedFrom != .checkIn)
        .onTapGesture {
            router.navigate(screen: .checkIn(checkIn))
        }
    }
}
