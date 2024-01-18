import Components
import EnvironmentModels
import Extensions
import Models
import Repositories
import SwiftUI

struct CheckInCard: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(Router.self) private var router
    let checkIn: CheckIn
    let loadedFrom: CheckInCard.LoadedFrom

    var body: some View {
        CheckInCardContainer {
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
            }.padding(.horizontal, 12)
            CheckInCardImage(imageUrl: checkIn.getImageUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl), blurHash: checkIn.blurHash)
            Group {
                CheckInCardCheckIn(checkIn: checkIn, loadedFrom: loadedFrom)
                CheckInCardTaggedFriends(taggedProfiles: checkIn.taggedProfiles.map(\.profile), loadedFrom: loadedFrom)
                CheckInCardFooter(checkIn: checkIn, loadedFrom: loadedFrom)
            }.padding(.horizontal, 12)
        }
        .allowsHitTesting(loadedFrom != .checkIn)
        .onTapGesture {
            router.navigate(screen: .checkIn(checkIn))
        }
        .accessibilityAddTraits(.isLink)
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
