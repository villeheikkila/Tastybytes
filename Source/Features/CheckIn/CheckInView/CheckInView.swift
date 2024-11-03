
import Extensions
import Models
import Repositories
import SwiftUI

struct CheckInView: View {
    @Namespace private var namespace
    @Environment(\.checkInLoadedFrom) private var checkInLoadedFrom
    @Environment(\.checkInHeaderVisibility) private var checkInHeaderVisibility
    @Environment(\.checkInFooterVisibility) private var checkInFooterVisibility
    @Environment(\.checkInContainerPadding) private var checkInContainerPadding

    let checkIn: CheckIn.Joined
    let onDeleteImage: CheckInImageSheet.OnDeleteImageCallback?

    init(checkIn: CheckIn.Joined, onDeleteImage: CheckInImageSheet.OnDeleteImageCallback? = nil) {
        self.checkIn = checkIn
        self.onDeleteImage = onDeleteImage
    }

    var body: some View {
        RouterLink(open: .screen(.checkIn(checkIn.id, namespace: namespace))) {
            VStack(spacing: 8) {
                VStack {
                    if checkInHeaderVisibility {
                        CheckInHeaderView(profile: checkIn.profile, location: checkIn.location)
                    }
                    RouterLink(open: .screen(.product(checkIn.product.id))) {
                        ProductView(product: checkIn.product, variant: checkIn.variant)
                            .productLogoLocation(.right)
                            .productCompanyLinkEnabled(checkInLoadedFrom != .product)
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal, checkInContainerPadding)
                if !checkIn.images.isEmpty {
                    CheckInImageReelView(checkIn: checkIn, onDeleteImage: onDeleteImage)
                }
                VStack {
                    CheckInCheckInSectionView(checkIn: checkIn)
                    CheckInTaggedFriendsView(taggedProfiles: checkIn.taggedProfiles.map(\.profile))
                    if checkInFooterVisibility {
                        CheckInFooterView(checkIn: checkIn)
                    }
                }
                .padding(.bottom, 8)
                .padding(.horizontal, checkInContainerPadding)
            }
            .routerLinkDisabled(false)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 16))
            .appleShadow()
        }
        .routerLinkDisabled(checkInLoadedFrom == .checkIn)
        .routerLinkMode(.button)
        .buttonStyle(.plain)
        .matchedTransitionSource(
            id: checkIn.id,
            in: namespace
        )
    }
}

extension EnvironmentValues {
    @Entry var checkInLoadedFrom: CheckInView.LoadedFrom = .checkIn
}

extension View {
    func checkInLoadedFrom(_ checkInLoadedFrom: CheckInView.LoadedFrom) -> some View {
        environment(\.checkInLoadedFrom, checkInLoadedFrom)
    }
}

extension EnvironmentValues {
    @Entry var checkInHeaderVisibility: Bool = true
}

extension View {
    func checkInHeaderVisibility(_ visible: Bool) -> some View {
        environment(\.checkInHeaderVisibility, visible)
    }
}

extension EnvironmentValues {
    @Entry var checkInFooterVisibility: Bool = true
}

extension View {
    func checkInFooterVisibility(_ visible: Bool) -> some View {
        environment(\.checkInFooterVisibility, visible)
    }
}

extension EnvironmentValues {
    @Entry var checkInContainerPadding: Double = 12
}

extension View {
    func checkInContainerPadding(_ padding: Double) -> some View {
        environment(\.checkInContainerPadding, padding)
    }
}

extension CheckInView {
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
