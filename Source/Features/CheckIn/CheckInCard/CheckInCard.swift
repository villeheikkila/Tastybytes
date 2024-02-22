import Components
import EnvironmentModels
import Extensions
import Models
import Repositories
import SwiftUI

struct CheckInCard: View {
    let checkIn: CheckIn
    let loadedFrom: CheckInCard.LoadedFrom

    var body: some View {
        CheckInCardContainer(checkIn: checkIn, loadedFrom: loadedFrom) {
            CheckInCardHeader(
                profile: checkIn.profile,
                loadedFrom: loadedFrom,
                location: checkIn.location
            )
            CheckInCardProduct(
                product: checkIn.product,
                loadedFrom: loadedFrom,
                productVariant: checkIn.variant,
                servingStyle: checkIn.servingStyle
            )
            CheckInCardImage(checkIn: checkIn)
            CheckInCardCheckIn(checkIn: checkIn, loadedFrom: loadedFrom)
            CheckInCardTaggedFriends(taggedProfiles: checkIn.taggedProfiles.map(\.profile), loadedFrom: loadedFrom)
            CheckInCardFooter(checkIn: checkIn, loadedFrom: loadedFrom)
        }
    }
}

extension CheckInCard {
    enum LoadedFrom: Equatable {
        case checkIn
        case product
        case profile(Profile)
        case activity(Profile)
        case location(Location)

        func isLoadedFromLocation(_ location: Location) -> Bool {
            switch self {
            case let .location(fromLocation):
                fromLocation == location
            default:
                false
            }
        }

        func isLoadedFromProfile(_ profile: Profile) -> Bool {
            switch self {
            case let .profile(fromProfile):
                fromProfile == profile
            default:
                false
            }
        }
    }
}
