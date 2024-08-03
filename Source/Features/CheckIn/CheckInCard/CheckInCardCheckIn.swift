import Components
import Models
import SwiftUI

struct CheckInCardCheckIn: View {
    @Environment(\.checkInLoadedFrom) private var checkInLoadedFrom
    let checkIn: CheckIn.Joined

    var body: some View {
        RouterLink(open: .screen(.checkIn(checkIn.id))) {
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

                FlavorsView(flavors: checkIn.flavors)

                if let purchaseLocation = checkIn.purchaseLocation {
                    RouterLink(open: .screen(.location(purchaseLocation.id))) {
                        HStack {
                            Text("checkIn.location.purchasedFrom __\(purchaseLocation.name)__")
                            Spacer()
                        }
                    }
                    .routerLinkDisabled(checkInLoadedFrom.isLoadedFromLocation(purchaseLocation))
                    .buttonStyle(.plain)
                }
            }
        }
        .routerLinkDisabled(checkInLoadedFrom == .checkIn)
    }
}
