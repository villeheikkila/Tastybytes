import Model
import NukeUI
import SwiftUI

struct CheckInCardView: View {
    @Environment(Router.self) private var router
    @State private var showFullPicture = false
    @State private var blurHashPlaceHolder: UIImage?
    @Environment(\.colorScheme) private var colorScheme

    let checkIn: CheckIn
    let loadedFrom: LoadedFrom

    private let spacing: Double = 4
    private let padding: Double = 10

    var body: some View {
        VStack(spacing: spacing) {
            Group {
                header
                productSection
            }
            .padding([.leading, .trailing], padding)
            checkInImage
            Group {
                checkInSection
                taggedProfilesSection
                footer
            }
            .padding([.leading, .trailing], padding)
        }
        .padding([.top, .bottom], padding)
        .background(colorScheme == .dark ? .thinMaterial : .ultraThin)
        .clipped()
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 2, y: 2)
        .if(loadedFrom != .checkIn) { view in
            view
                .onTapGesture {
                    router.navigate(screen: .checkIn(checkIn))
                }
                .accessibilityAddTraits(.isLink)
        }
    }

    private var header: some View {
        HStack {
            AvatarView(avatarUrl: checkIn.profile.avatarUrl, size: 24, id: checkIn.profile.id)
            Text(checkIn.profile.preferredName)
                .font(.caption).bold()
                .foregroundColor(.primary)
            Spacer()
            if let location = checkIn.location {
                Text("\(location.name) \(location.country?.emoji ?? "")")
                    .font(.caption).bold()
                    .foregroundColor(.primary)
                    .if(!loadedFrom.isLoadedFromLocation(location)) { view in
                        view
                            .contentShape(Rectangle())
                            .accessibilityAddTraits(.isLink)
                            .onTapGesture {
                                router.navigate(screen: .location(location))
                            }
                    }
            }
        }
        .if(!loadedFrom.isLoadedFromProfile(checkIn.profile)) { view in
            view
                .contentShape(Rectangle())
                .accessibilityAddTraits(.isLink)
                .onTapGesture {
                    router.navigate(screen: .profile(checkIn.profile))
                }
        }
    }

    @MainActor
    @ViewBuilder private var checkInImage: some View {
        if let imageUrl = checkIn.imageUrl {
            LazyImage(url: imageUrl) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .contentShape(Rectangle())
                        .if(!isMac(), transform: { view in
                            view
                                .onTapGesture {
                                    showFullPicture = true
                                }
                                .accessibility(addTraits: .isButton)
                        })
                        .popover(isPresented: $showFullPicture) {
                            LazyImage(url: imageUrl) { state in
                                if let image = state.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    ProgressView()
                                }
                            }
                        }
                } else {
                    BlurHashPlaceholder(blurHash: checkIn.blurHash, height: 200)
                }
            }
            .frame(height: 200)
            .padding([.top, .bottom], spacing)
        }
    }

    @MainActor
    private var productSection: some View {
        HStack(spacing: spacing) {
            if let logoUrl = checkIn.product.logoUrl {
                LazyImage(url: logoUrl) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 32, height: 32)
                            .accessibility(hidden: true)
                    } else {
                        ProgressView()
                    }
                }
                .padding(.leading, padding)
            }
            VStack(alignment: .leading, spacing: spacing) {
                CategoryView(
                    category: checkIn.product.category,
                    subcategories: checkIn.product.subcategories,
                    servingStyle: checkIn.servingStyle
                )

                Text(checkIn.product.getDisplayName(.fullName))
                    .font(.headline)
                    .foregroundColor(.primary)

                if let description = checkIn.product.description {
                    Text(description)
                        .font(.caption)
                }

                HStack {
                    Text(checkIn.product.getDisplayName(.brandOwner))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .contentShape(Rectangle())
                        .accessibilityAddTraits(.isLink)
                        .onTapGesture {
                            router.navigate(screen: .company(checkIn.product.subBrand.brand.brandOwner))
                        }

                    if let manufacturer = checkIn.variant?.manufacturer,
                       manufacturer.id != checkIn.product.subBrand.brand.brandOwner.id
                    {
                        Text("(\(manufacturer.name))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
            }
        }
        .if(loadedFrom != .product) { view in
            view
                .contentShape(Rectangle())
                .accessibilityAddTraits(.isLink)
                .onTapGesture {
                    router.navigate(screen: .product(checkIn.product))
                }
        }
    }

    @ViewBuilder private var checkInSection: some View {
        VStack(alignment: .leading, spacing: spacing) {
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

            FlavorsView(flavors: checkIn.flavors)

            if let purchaseLocation = checkIn.purchaseLocation {
                HStack {
                    Text("Purchased from __\(purchaseLocation.name)__")
                        .if(!loadedFrom.isLoadedFromLocation(purchaseLocation)) { view in
                            view.accessibilityAddTraits(.isLink)
                                .onTapGesture {
                                    router.navigate(screen: .location(purchaseLocation))
                                }
                        }
                    Spacer()
                }
            }
        }
        .if(loadedFrom != .checkIn) { view in
            view
                .contentShape(Rectangle())
                .accessibilityAddTraits(.isLink)
                .onTapGesture {
                    router.navigate(screen: .checkIn(checkIn))
                }
        }
    }

    @ViewBuilder private var taggedProfilesSection: some View {
        if !checkIn.taggedProfiles.isEmpty {
            VStack(spacing: spacing) {
                HStack {
                    Text(verbatim: "Tagged friends")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                }
                HStack(spacing: spacing) {
                    ForEach(checkIn.taggedProfiles) { taggedProfile in
                        AvatarView(avatarUrl: taggedProfile.avatarUrl, size: 24, id: taggedProfile.id)
                            .if(!loadedFrom.isLoadedFromProfile(taggedProfile)) { view in
                                view
                                    .contentShape(Rectangle())
                                    .accessibilityAddTraits(.isLink)
                                    .onTapGesture {
                                        router.navigate(screen: .profile(taggedProfile))
                                    }
                            }
                    }
                    Spacer()
                }
            }
        }
    }

    private var footer: some View {
        HStack {
            HStack {
                if let checkInAt = checkIn.checkInAt {
                    Text(checkInAt.customFormat(.relativeTime))
                        .font(.caption)
                        .bold()
                } else {
                    Text("legacy check-in")
                        .font(.caption)
                        .bold()
                }
                Spacer()
            }
            .if(loadedFrom != .checkIn) { view in
                view
                    .contentShape(Rectangle())
                    .accessibilityAddTraits(.isLink)
                    .onTapGesture {
                        router.navigate(screen: .checkIn(checkIn))
                    }
            }
            ReactionsView(checkIn: checkIn)
        }
    }
}

extension CheckInCardView {
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
