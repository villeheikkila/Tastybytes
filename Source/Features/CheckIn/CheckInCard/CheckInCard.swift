import EnvironmentModels
import Extensions
import Models
import Repositories
import SwiftUI

struct CheckInCard: View {
    @Environment(\.checkInCardLoadedFrom) private var checkInCardLoadedFrom
    let checkIn: CheckIn
    let onDeleteImage: CheckInImageSheet.OnDeleteImageCallback?

    var body: some View {
        RouterLink(open: .screen(.checkIn(checkIn))) {
            VStack(spacing: 4) {
                Group {
                    CheckInCardHeader(profile: checkIn.profile, location: checkIn.location)
                    CheckInCardProduct(product: checkIn.product, productVariant: checkIn.variant, servingStyle: checkIn.servingStyle)
                }
                .padding(.horizontal, 8)
                if !checkIn.images.isEmpty {
                    CheckInImageReelView(checkIn: checkIn, onDeleteImage: onDeleteImage)
                }
                Group {
                    CheckInCardCheckIn(checkIn: checkIn)
                    CheckInCardTaggedFriends(taggedProfiles: checkIn.taggedProfiles.map(\.profile))
                    CheckInCardFooter(checkIn: checkIn)
                }
                .padding(.horizontal, 8)
            }
            .routerLinkDisabled(false)
        }
        .routerLinkDisabled(checkInCardLoadedFrom == .checkIn)
        .routerLinkMode(.button)
        .buttonStyle(.plain)
    }
}

extension EnvironmentValues {
    @Entry var checkInCardLoadedFrom: CheckInCard.LoadedFrom = .checkIn
}

extension View {
    func checkInCardLoadedFrom(_ checkInCardLoadedFrom: CheckInCard.LoadedFrom) -> some View {
        environment(\.checkInCardLoadedFrom, checkInCardLoadedFrom)
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
