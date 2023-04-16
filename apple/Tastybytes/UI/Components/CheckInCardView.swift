import CachedAsyncImage
import Combine
import SwiftUI
import WrappingHStack

struct CheckInCardView: View {
  @EnvironmentObject private var client: AppClient
  @EnvironmentObject private var router: Router
  @State private var showFullPicture = false
  @State private var blurHashPlaceHolder: UIImage?
  @Environment(\.colorScheme) private var colorScheme

  let checkIn: CheckIn
  let loadedFrom: LoadedFrom

  var body: some View {
    VStack {
      VStack {
        header
        productSection
      }
      .padding([.leading, .trailing], 10)
      checkInImage
      VStack(spacing: 4) {
        checkInSection
        taggedProfilesSection
        footer
      }
      .padding([.leading, .trailing], 10)
    }
    .padding([.top, .bottom], 10)
    .background(colorScheme == .dark ? .thinMaterial : .ultraThin)
    .clipped()
    .cornerRadius(8)
    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 2, y: 2)
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

  @ViewBuilder private var checkInImage: some View {
    if let imageUrl = checkIn.imageUrl {
      CachedAsyncImage(url: imageUrl, urlCache: .imageCache) { image in
        image
          .resizable()
          .scaledToFill()
          .frame(height: 200)
          .clipped()
          .contentShape(Rectangle())
          .accessibility(addTraits: .isButton)
          .onTapGesture {
            showFullPicture = true
          }
          .popover(isPresented: $showFullPicture) {
            CachedAsyncImage(url: imageUrl, urlCache: .imageCache) { image in
              image
                .resizable()
                .scaledToFill()
            } placeholder: {
              ProgressView()
            }
          }
      } placeholder: {
        BlurHashPlaceholder(blurHash: checkIn.blurHash)
      }.frame(height: 200)
    }
  }

  private var productSection: some View {
    HStack(spacing: 12) {
      if let logoUrl = checkIn.product.logoUrl {
        CachedAsyncImage(url: logoUrl, urlCache: .imageCache) { image in
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
          CategoryView(category: checkIn.product.category, subcategories: checkIn.product.subcategories)
          Spacer()
          if let servingStyle = checkIn.servingStyle {
            ServingStyleLabelView(servingStyle: servingStyle)
          }
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
    if !checkIn.isEmpty {
      VStack(alignment: .leading, spacing: 8) {
        if let rating = checkIn.rating {
          RatingView(rating: rating)
        }

        if let review = checkIn.review {
          Text(review)
            .fontWeight(.medium)
            .foregroundColor(.primary)
        }

        WrappingHStack(checkIn.flavors, spacing: .constant(4)) { flavor in
          ChipView(title: flavor.label)
        }

        if let purchaseLocation = checkIn.purchaseLocation {
          Text("Purchased from __\(purchaseLocation.name)__")
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
  }

  @ViewBuilder private var taggedProfilesSection: some View {
    if !checkIn.taggedProfiles.isEmpty {
      VStack(spacing: 4) {
        HStack {
          Text(verbatim: "Tagged friends")
            .font(.subheadline)
            .fontWeight(.medium)
          Spacer()
        }
        HStack(spacing: 4) {
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
            .font(.caption).bold()
        } else {
          Text("legacy check-in")
            .font(.caption).bold()
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
        return fromLocation == location
      default:
        return false
      }
    }

    func isLoadedFromProfile(_ profile: Profile) -> Bool {
      switch self {
      case let .profile(fromProfile):
        return fromProfile == profile
      default:
        return false
      }
    }
  }
}
