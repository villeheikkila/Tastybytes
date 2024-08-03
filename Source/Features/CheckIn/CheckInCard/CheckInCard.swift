
import Extensions
import Models
import Repositories
import SwiftUI

struct CheckInCard: View {
    @Environment(\.checkInCardLoadedFrom) private var checkInCardLoadedFrom
    @Environment(\.checkInCardHeaderVisibility) private var checkInCardHeaderVisibility
    @Environment(\.checkInCardFooterVisibility) private var checkInCardFooterVisibility

    let checkIn: CheckIn.Joined
    let onDeleteImage: CheckInImageSheet.OnDeleteImageCallback?
    
    init(checkIn: CheckIn.Joined, onDeleteImage: CheckInImageSheet.OnDeleteImageCallback? = nil) {
        self.checkIn = checkIn
        self.onDeleteImage = onDeleteImage
    }

    var body: some View {
        RouterLink(open: .screen(.checkIn(checkIn.id))) {
            VStack(spacing: 4) {
                Group {
                    if checkInCardHeaderVisibility {
                        CheckInCardHeader(profile: checkIn.profile, location: checkIn.location)
                    }
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
                    if checkInCardFooterVisibility {
                        CheckInCardFooter(checkIn: checkIn)
                    }
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

extension EnvironmentValues {
    @Entry var checkInCardHeaderVisibility: Bool = true
}

extension View {
    func checkInCardHeaderVisibility(_ visible: Bool) -> some View {
        environment(\.checkInCardHeaderVisibility, visible)
    }
}

extension EnvironmentValues {
    @Entry var checkInCardFooterVisibility: Bool = true
}

extension View {
    func checkInCardFooterVisibility(_ visible: Bool) -> some View {
        environment(\.checkInCardFooterVisibility, visible)
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
