
import Extensions
import Models
import Repositories
import SwiftUI

struct CheckInCard: View {
    @Environment(\.checkInCardLoadedFrom) private var checkInCardLoadedFrom
    let checkIn: CheckIn.Joined
    let onDeleteImage: CheckInImageSheet.OnDeleteImageCallback?

    var body: some View {
        RouterLink(open: .screen(.checkIn(checkIn.id))) {
            VStack(spacing: 4) {
                Group {
                    CheckInCardHeader(profile: checkIn.profile, location: checkIn.location)
                    RouterLink(open: .screen(.product(checkIn.product.id))) {
                        ProductEntityView(product: checkIn.product, variant: checkIn.variant)
                            .productLogoLocation(.right)
                            .productCompanyLinkEnabled(checkInCardLoadedFrom != .product)
                    }
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
        case profile(Profile.Saved)
        case activity(Profile.Saved)
        case location(Location.Saved)

        func isLoadedFromLocation(_ location: Location.Saved) -> Bool {
            switch self {
            case let .location(fromLocation):
                fromLocation == location
            default:
                false
            }
        }

        func isLoadedFromProfile(_ profile: Profile.Saved) -> Bool {
            switch self {
            case let .profile(fromProfile):
                fromProfile == profile
            default:
                false
            }
        }
    }
}
