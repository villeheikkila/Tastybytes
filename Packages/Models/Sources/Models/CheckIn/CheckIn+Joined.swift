import Foundation
public import Tagged

public extension CheckIn {
    struct Joined: Identifiable, Hashable, Codable, Sendable {
        public let id: CheckIn.Id
        public let rating: Double?
        public let review: String?
        public let checkInAt: Date?
        public let profile: Profile.Saved
        public let product: Product.Joined
        public let checkInReactions: [CheckIn.Reaction.Saved]
        public let taggedProfiles: [CheckInTaggedProfile]
        public let flavors: [Flavor.Saved]
        public let variant: Product.Variant.JoinedCompany?
        public let servingStyle: ServingStyle.Saved?
        public let location: Location.Saved?
        public let purchaseLocation: Location.Saved?
        public let images: [ImageEntity.Saved]
        public let isNostalgic: Bool

        public init(
            id: CheckIn.Id,
            rating: Double? = nil,
            review: String? = nil,
            checkInAt: Date? = nil,
            profile: Profile.Saved,
            product: Product.Joined,
            checkInReactions: [CheckIn.Reaction.Saved],
            taggedProfiles: [CheckInTaggedProfile],
            flavors: [Flavor.Saved],
            variant: Product.Variant.JoinedCompany? = nil,
            servingStyle: ServingStyle.Saved? = nil,
            location: Location.Saved? = nil,
            purchaseLocation: Location.Saved? = nil,
            images: [ImageEntity.Saved],
            isNostalgic: Bool = false
        ) {
            self.id = id
            self.rating = rating
            self.review = review
            self.checkInAt = checkInAt
            self.profile = profile
            self.product = product
            self.checkInReactions = checkInReactions
            self.taggedProfiles = taggedProfiles
            self.flavors = flavors
            self.variant = variant
            self.servingStyle = servingStyle
            self.location = location
            self.purchaseLocation = purchaseLocation
            self.images = images
            self.isNostalgic = isNostalgic
        }

        public init(checkIn: CheckIn.Detailed) {
            id = checkIn.id
            rating = checkIn.rating
            review = checkIn.review
            checkInAt = checkIn.checkInAt
            profile = checkIn.createdBy
            product = checkIn.product
            checkInReactions = checkIn.checkInReactions
            taggedProfiles = checkIn.taggedProfiles
            flavors = checkIn.flavors
            variant = checkIn.variant
            servingStyle = checkIn.servingStyle
            location = checkIn.location
            purchaseLocation = checkIn.purchaseLocation
            images = checkIn.images
            isNostalgic = checkIn.isNostalgic
        }

        public init() {
            id = .init(0)
            rating = nil
            review = nil
            checkInAt = nil
            product = .init()
            checkInReactions = []
            taggedProfiles = []
            flavors = []
            variant = nil
            servingStyle = nil
            location = nil
            purchaseLocation = nil
            images = []
            isNostalgic = false
            profile = .init()
        }

        public var isEmpty: Bool {
            [rating == nil, review.isNilOrEmpty, flavors.isEmpty, purchaseLocation == nil].allSatisfy { $0 }
        }

        public func copyWith(
            rating: Double? = nil,
            review: String? = nil,
            checkInAt: Date? = nil,
            profile: Profile.Saved? = nil,
            product: Product.Joined? = nil,
            checkInReactions: [CheckIn.Reaction.Saved]? = nil,
            taggedProfiles: [CheckInTaggedProfile]? = nil,
            flavors: [Flavor.Saved]? = nil,
            variant: Product.Variant.JoinedCompany? = nil,
            servingStyle: ServingStyle.Saved? = nil,
            location: Location.Saved? = nil,
            purchaseLocation: Location.Saved? = nil,
            isNostalgic: Bool? = nil,
            images: [ImageEntity.Saved]? = nil
        ) -> Self {
            .init(
                id: id,
                rating: rating ?? self.rating,
                review: review ?? self.review,
                checkInAt: checkInAt ?? self.checkInAt,
                profile: profile ?? self.profile,
                product: product ?? self.product,
                checkInReactions: checkInReactions ?? self.checkInReactions,
                taggedProfiles: taggedProfiles ?? self.taggedProfiles,
                flavors: flavors ?? self.flavors,
                variant: variant ?? self.variant,
                servingStyle: servingStyle ?? self.servingStyle,
                location: location ?? self.location,
                purchaseLocation: purchaseLocation ?? self.purchaseLocation,
                images: images ?? self.images,
                isNostalgic: isNostalgic ?? self.isNostalgic
            )
        }

        enum CodingKeys: String, CodingKey {
            case id
            case rating
            case review
            case checkInAt = "check_in_at"
            case profile = "profiles"
            case product = "products"
            case checkInReactions = "check_in_reactions"
            case taggedProfiles = "check_in_tagged_profiles"
            case flavors
            case variant = "product_variants"
            case servingStyle = "serving_styles"
            case location = "locations"
            case purchaseLocation = "purchase_location"
            case images = "check_in_images"
            case isNostalgic = "is_nostalgic"
        }
    }
}
