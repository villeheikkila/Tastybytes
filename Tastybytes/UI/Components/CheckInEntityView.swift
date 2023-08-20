import Model
import NukeUI
import SwiftUI

struct CheckInEntityView: View {
    let checkIn: CheckIn

    var body: some View {
        VStack {
            VStack {
                header
                productSection
            }
            checkInImage
            VStack(alignment: .leading, spacing: 4) {
                checkInSection
                taggedProfilesSection
                footer
            }
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
            }
        }
    }

    @MainActor
    @ViewBuilder private var checkInImage: some View {
        if let imageUrl = checkIn.imageUrl {
            HStack {
                LazyImage(url: imageUrl) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipped()
                            .contentShape(Rectangle())
                    } else {
                        BlurHashPlaceholder(blurHash: checkIn.blurHash, height: 200)
                    }
                }.frame(height: 200)
            }
        }
    }

    private var productSection: some View {
        HStack(spacing: 12) {
            if let logoUrl = checkIn.product.logoUrl {
                AsyncImage(url: logoUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 32, height: 32)
                        .accessibility(hidden: true)
                } placeholder: {
                    ProgressView()
                }
                .padding(.leading, 10)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    CategoryView(
                        category: checkIn.product.category,
                        subcategories: checkIn.product.subcategories,
                        servingStyle: checkIn.servingStyle
                    )
                    Spacer()
                }

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
    }

    @ViewBuilder private var checkInSection: some View {
        if !checkIn.isEmpty {
            if let rating = checkIn.rating {
                HStack {
                    RatingView(rating: rating)
                    Spacer()
                }
            }

            if let review = checkIn.review {
                Text(review)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }

            FlavorsView(flavors: checkIn.flavors)
            if let purchaseLocation = checkIn.purchaseLocation {
                Text("Purchased from __\(purchaseLocation.name)__")
            }
        }
    }

    @ViewBuilder private var taggedProfilesSection: some View {
        if !checkIn.taggedProfiles.isEmpty {
            HStack {
                Text(verbatim: "Tagged friends")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
            }
            HStack(spacing: 4) {
                ForEach(checkIn.taggedProfiles) { taggedProfile in
                    AvatarView(avatarUrl: taggedProfile.avatarUrl, size: 24, id: taggedProfile.id)
                }
                Spacer()
            }
        }
    }

    private var footer: some View {
        HStack {
            if let checkInAt = checkIn.checkInAt {
                Text(checkInAt.customFormat(.relativeTime))
                    .font(.caption).bold()
            } else {
                Text("legacy check-in")
                    .font(.caption).bold()
            }
            Spacer()
        }
    }
}
