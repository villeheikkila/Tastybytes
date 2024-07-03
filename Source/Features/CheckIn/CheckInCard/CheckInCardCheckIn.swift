import Components
import Models
import SwiftUI

struct CheckInCardCheckIn: View {
    let checkIn: CheckIn
    let loadedFrom: CheckInCard.LoadedFrom

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let rating = checkIn.rating {
                HStack {
                    RatingView(rating: rating)
                        .ratingColor(checkIn.isNostalgic ? .purple : .yellow)
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
                    Text("checkIn.location.purchasedFrom __\(purchaseLocation.name)__")
                        .accessibilityAddTraits(.isLink)
                        .allowsHitTesting(!loadedFrom.isLoadedFromLocation(purchaseLocation))
                        .openOnTap(.screen(.location(purchaseLocation)))

                    Spacer()
                }
            }
        }
        .contentShape(.rect)
        .accessibilityAddTraits(.isLink)
        .allowsHitTesting(loadedFrom != .checkIn)
        .openOnTap(.screen(.checkIn(checkIn)))
    }
}
