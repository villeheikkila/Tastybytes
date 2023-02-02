import CachedAsyncImage
import SwiftUI
import WrappingHStack

struct CheckInCardView: View {
  @State private var showFullPicture = false
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
      VStack {
        checkInSection
        taggedProfilesSection
        footer
      }
      .padding([.leading, .trailing], 10)
    }
    .padding([.top, .bottom], 10)
    .background(Color(.tertiarySystemBackground))
    .clipped()
    .cornerRadius(8)
    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 2, y: 2)
  }

  private var header: some View {
    OptionalNavigationLink(
      value: Route.profile(checkIn.profile),
      disabled: loadedFrom.isLoadedFromProfile(checkIn.profile)
    ) {
      HStack {
        AvatarView(avatarUrl: checkIn.profile.getAvatarURL(), size: 24, id: checkIn.profile.id)
        Text(checkIn.profile.preferredName)
          .font(.system(size: 10, weight: .bold, design: .default))
          .foregroundColor(.primary)
        Spacer()
        if let location = checkIn.location {
          OptionalNavigationLink(
            value: Route.location(location),
            disabled: loadedFrom.isLoadedFromLocation(location)
          ) {
            Text("\(location.name) \(location.country?.emoji ?? "")")
              .font(.system(size: 10, weight: .bold, design: .default))
              .foregroundColor(.primary)
          }
        }
      }
    }
  }

  @ViewBuilder
  private var checkInImage: some View {
    if let imageUrl = checkIn.getImageUrl() {
      Button(action: {
        showFullPicture = true
      }) {
        CachedAsyncImage(url: imageUrl, urlCache: .imageCache) { image in
          image
            .resizable()
            .scaledToFill()
            .frame(height: 200)
            .clipped()
        } placeholder: {
          ProgressView()
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
      }
    }
  }

  private var productSection: some View {
    OptionalNavigationLink(value: Route.product(checkIn.product), disabled: loadedFrom == .product) {
      VStack(alignment: .leading, spacing: 2) {
        HStack {
          CategoryNameView(category: checkIn.product.category)

          ForEach(checkIn.product.subcategories, id: \.id) { subcategory in
            ChipView(title: subcategory.name, cornerRadius: 5)
          }

          Spacer()

          if let servingStyle = checkIn.servingStyle {
            ServingStyleLabelView(servingStyleName: servingStyle.name)
          }
        }

        Text(checkIn.product.getDisplayName(.fullName))
          .font(.system(size: 16, weight: .bold, design: .default))
          .foregroundColor(.primary)

        if let description = checkIn.product.description {
          Text(description)
            .font(.system(size: 10, weight: .medium, design: .default))
        }

        HStack {
          NavigationLink(
            value: Route.company(checkIn.product.subBrand.brand.brandOwner)
          ) {
            Text(checkIn.product.getDisplayName(.brandOwner))
              .font(.system(size: 14, weight: .bold, design: .default))
              .foregroundColor(.secondary)
              .lineLimit(nil)
          }

          if let manufacturer = checkIn.variant?.manufacturer,
             manufacturer.id != checkIn.product.subBrand.brand.brandOwner.id
          {
            Text("(\(manufacturer.name))")
              .font(.system(size: 14, weight: .bold, design: .default))
              .foregroundColor(.secondary)
              .lineLimit(nil)
          }

          Spacer()
        }
      }
    }
  }

  @ViewBuilder
  private var checkInSection: some View {
    if !checkIn.isEmpty {
      OptionalNavigationLink(
        value: Route.checkIn(checkIn),
        disabled: loadedFrom == .checkIn
      ) {
        VStack(alignment: .leading, spacing: 6) {
          if let rating = checkIn.rating {
            RatingView(rating: rating)
          }

          if let review = checkIn.review {
            Text(review)
              .fontWeight(.medium)
              .foregroundColor(.primary)
          }

          if let flavors = checkIn.flavors {
            WrappingHStack(flavors, id: \.self, spacing: .constant(4)) {
              flavor in
              ChipView(title: flavor.name.capitalized, cornerRadius: 5)
            }
          }
        }
      }
    }
  }

  @ViewBuilder
  private var taggedProfilesSection: some View {
    if checkIn.taggedProfiles.count > 0 {
      VStack(spacing: 4) {
        HStack {
          Text(verbatim: "Tagged friends")
            .font(.subheadline)
            .fontWeight(.medium)
          Spacer()
        }
        HStack(spacing: 4) {
          ForEach(checkIn.taggedProfiles, id: \.id) {
            taggedProfile in
            OptionalNavigationLink(
              value: Route.profile(taggedProfile),
              disabled: loadedFrom.isLoadedFromProfile(taggedProfile)
            ) {
              AvatarView(avatarUrl: taggedProfile.getAvatarURL(), size: 14, id: taggedProfile.id)
            }
          }
          Spacer()
        }
      }
    }
  }

  private var footer: some View {
    HStack {
      OptionalNavigationLink(value: Route.checkIn(checkIn), disabled: loadedFrom == .checkIn) {
        Text(checkIn.isMigrated ? "legacy check-in" : checkIn.createdAt.relativeTime())
          .font(.system(size: 10, weight: .medium, design: .default))
        Spacer()
      }
      Spacer()
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

struct CheckInCardView_Previews: PreviewProvider {
  static let company = Company(id: 0, name: "The Coca Cola Company", logoUrl: nil, isVerified: true)

  static let product = Product.Joined(
    id: 0,
    name: "Coca Cola",
    description: "Original Taste",
    isVerified: true,
    subBrand: subBrand,
    category: category,
    subcategories: subcategories,
    barcodes: []
  )

  static let profile = Profile(
    id: UUID(uuidString: "82c34cc0-4795-4478-99ad-38003fdb65fd") ?? UUID(),
    preferredName: "villeheikkila",
    avatarUrl: "avatar.jpeg"
  )

  static let servingStyle = ServingStyle(id: 0, name: .bottle)

  static let hartwallCompany = Company(id: 0, name: "Hartwall", logoUrl: nil, isVerified: true)

  static let variant = ProductVariant(id: 0, manufacturer: hartwallCompany)

  static let category = Category(id: 0, name: .beverage)

  static let categoryJoined = Category.JoinedSubcategories(
    id: 0,
    name: .beverage,
    subcategories: [Subcategory(id: 0, name: "Soda")]
  )

  static let flavors = [Flavor(id: 0, name: "Cola")]

  static let checkInReactions = [CheckInReaction(id: 0, profile: profile)]

  static let subcategories = [Subcategory.JoinedCategory(id: 0, name: "Soda", category: category)]

  static let brand = Brand.JoinedCompany(id: 0, name: "Coca Cola", isVerified: true, brandOwner: company)

  static let subBrand = SubBrand.JoinedBrand(id: 0, name: "Zero", isVerified: false, brand: brand)

  static let country = Country(countryCode: "FI", name: "Finland", emoji: "🇫🇮")

  static let location = Location(
    id: UUID(),
    name: "McDonalds",
    title: "Mäkkäri",
    location: nil,
    countryCode: "FI",
    country: country
  )

  static let checkIn = CheckIn(
    id: 0,
    rating: 2.5,
    review: "Pretty Good!",
    imageUrl: "IMG_3155.jpeg",
    createdAt: Date(),
    isMigrated: false,
    profile: profile,
    product: product,
    checkInReactions: checkInReactions,
    taggedProfiles: [profile],
    flavors: flavors,
    variant: variant,
    servingStyle: servingStyle,
    location: location
  )

  static var previews: some View {
    CheckInCardView(
      checkIn: checkIn,
      loadedFrom: .checkIn
    )
  }
}
