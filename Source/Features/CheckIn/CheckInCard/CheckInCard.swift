import EnvironmentModels
import Extensions
import Models
import Repositories
import SwiftUI

struct CheckInCard: View {
    let checkIn: CheckIn
    let loadedFrom: CheckInCard.LoadedFrom
    let onDeleteImage: CheckInImageSheet.OnDeleteImageCallback?

    var body: some View {
        RouterLink(open: .screen(.checkIn(checkIn))) {
            VStack(spacing: 4) {
                    Group {
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
                    }
                    .padding(.horizontal, 8)
                    if !checkIn.images.isEmpty {
                        CheckInImageReelView(checkIn: checkIn, onDeleteImage: onDeleteImage)
                    }
                    Group {
                        CheckInCardCheckIn(checkIn: checkIn, loadedFrom: loadedFrom)
                        CheckInCardTaggedFriends(taggedProfiles: checkIn.taggedProfiles.map(\.profile), loadedFrom: loadedFrom)
                        CheckInCardFooter(checkIn: checkIn, loadedFrom: loadedFrom)
                    }
                    .padding(.horizontal, 8)
            }
            .routerLinkDisabled(false)
        }
        .routerLinkDisabled(loadedFrom == .checkIn)
        .routerLinkMode(.button)
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
