import Extensions
import Foundation

public struct CheckIn: Identifiable, Hashable, Codable, Sendable {
    public let id: Int
    public let rating: Double?
    public let review: String?
    public let checkInAt: Date?
    public let profile: Profile
    public let product: Product.Joined
    public let checkInReactions: [CheckInReaction]
    public let taggedProfiles: [CheckInTaggedProfile]
    public let flavors: [CheckInFlavor]
    public let variant: ProductVariant?
    public let servingStyle: ServingStyle?
    public let location: Location?
    public let purchaseLocation: Location?
    public let images: [ImageEntity]
    public let isNostalgic: Bool

    public var isEmpty: Bool {
        [rating == nil, review.isNilOrEmpty, flavors.isEmpty, purchaseLocation == nil].allSatisfy { $0 }
    }

    public init(
        id: Int,
        rating: Double? = nil,
        review: String? = nil,
        checkInAt: Date? = nil,
        profile: Profile,
        product: Product.Joined,
        checkInReactions: [CheckInReaction],
        taggedProfiles: [CheckInTaggedProfile],
        flavors: [CheckInFlavor],
        variant: ProductVariant? = nil,
        servingStyle: ServingStyle? = nil,
        location: Location? = nil,
        purchaseLocation: Location? = nil,
        images: [ImageEntity],
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

    public func copyWith(
        rating: Double? = nil,
        review: String? = nil,
        checkInAt: Date? = nil,
        profile: Profile? = nil,
        product: Product.Joined? = nil,
        checkInReactions: [CheckInReaction]? = nil,
        taggedProfiles: [CheckInTaggedProfile]? = nil,
        flavors: [CheckInFlavor]? = nil,
        variant: ProductVariant? = nil,
        servingStyle: ServingStyle? = nil,
        location: Location? = nil,
        purchaseLocation: Location? = nil,
        isNostalgic: Bool? = nil,
        images: [ImageEntity]? = nil
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
        case flavors = "check_in_flavors"
        case variant = "product_variants"
        case servingStyle = "serving_styles"
        case location = "locations"
        case purchaseLocation = "purchase_location"
        case images = "check_in_images"
        case isNostalgic = "is_nostalgic"
    }
}

public extension CheckIn {
    struct CheckInTaggedProfile: Codable, Sendable, Hashable {
        public let profile: Profile

        enum CodingKeys: String, CodingKey {
            case profile = "profiles"
        }
    }

    struct CheckInFlavor: Codable, Sendable, Hashable {
        public let flavor: Flavor

        enum CodingKeys: String, CodingKey {
            case flavor = "flavors"
        }
    }

    struct Image: Hashable, Sendable, Identifiable, Codable {
        public let id: Int
        public let createdBy: UUID
        public let images: [ImageEntity]

        enum CodingKeys: String, CodingKey {
            case id
            case images = "check_in_images"
            case createdBy = "created_by"
        }
    }

    struct Minimal: Codable, Hashable, Sendable, Identifiable {
        public let id: Int
        public let createdBy: UUID

        enum CodingKeys: String, CodingKey {
            case id
            case createdBy = "created_by"
        }
    }

    struct DeleteAsAdminRequest: Codable, Sendable {
        public let id: Int

        public init(checkIn: CheckIn) {
            id = checkIn.id
        }

        enum CodingKeys: String, CodingKey {
            case id = "p_check_in_id"
        }
    }

    struct NewRequest: Codable, Sendable {
        public let productId: Int
        public let rating: Double?
        public let review: String?
        public let manufacturerId: Int?
        public let servingStyleId: Int?
        public let friendIds: [String]?
        public let flavorIds: [Int]?
        public let locationId: String?
        public let purchaseLocationId: String?
        public let checkInAt: Date?
        public let isNostalgic: Bool

        enum CodingKeys: String, CodingKey {
            case productId = "p_product_id"
            case rating = "p_rating"
            case review = "p_review"
            case manufacturerId = "p_manufacturer_id"
            case servingStyleId = "p_serving_style_id"
            case friendIds = "p_friend_ids"
            case flavorIds = "p_flavor_ids"
            case locationId = "p_location_id"
            case purchaseLocationId = "p_purchase_location_id"
            case checkInAt = "p_check_in_at"
            case isNostalgic = "p_is_nostalgic"
        }

        public init(
            product: Product.Joined,
            review: String?,
            taggedFriends: [Profile],
            servingStyle: ServingStyle?,
            manufacturer: Company?,
            flavors: [Flavor],
            rating: Double,
            location: Location?,
            purchaseLocation: Location?,
            checkInAt: Date?,
            isNostalgic: Bool
        ) {
            productId = product.id
            self.review = review.isNilOrEmpty ? nil : review
            manufacturerId = manufacturer?.id
            servingStyleId = servingStyle?.id
            friendIds = taggedFriends.map(\.id.uuidString)
            flavorIds = flavors.map(\.id)
            self.rating = rating
            locationId = location?.id.uuidString
            purchaseLocationId = purchaseLocation?.id.uuidString
            self.checkInAt = checkInAt
            self.isNostalgic = isNostalgic
        }
    }

    struct UpdateRequest: Codable, Sendable {
        public let checkInId: Int
        public let productId: Int
        public let rating: Double?
        public let review: String?
        public let manufacturerId: Int?
        public let servingStyleId: Int?
        public let friendIds: [String]?
        public let flavorIds: [Int]?
        public let locationId: String?
        public let purchaseLocationId: String?
        public let checkInAt: Date?
        public let isNostalgic: Bool

        enum CodingKeys: String, CodingKey {
            case checkInId = "p_check_in_id"
            case productId = "p_product_id"
            case rating = "p_rating"
            case review = "p_review"
            case manufacturerId = "p_manufacturer_id"
            case servingStyleId = "p_serving_style_id"
            case friendIds = "p_friend_ids"
            case flavorIds = "p_flavor_ids"
            case locationId = "p_location_id"
            case purchaseLocationId = "p_purchase_location_id"
            case checkInAt = "p_check_in_at"
            case isNostalgic = "p_is_nostalgic"
        }

        public init(
            checkIn: CheckIn,
            product: Product.Joined,
            review: String?,
            taggedFriends: [Profile],
            servingStyle: ServingStyle?,
            manufacturer: Company?,
            flavors: [Flavor],
            rating: Double,
            location: Location?,
            purchaseLocation: Location?,
            checkInAt: Date?,
            isNostalgic: Bool
        ) {
            checkInId = checkIn.id
            productId = product.id
            self.review = review
            manufacturerId = manufacturer?.id
            servingStyleId = servingStyle?.id
            friendIds = taggedFriends.map(\.id.uuidString)
            flavorIds = flavors.map(\.id)
            self.rating = rating
            locationId = location?.id.uuidString
            purchaseLocationId = purchaseLocation?.id.uuidString
            self.checkInAt = checkInAt
            self.isNostalgic = isNostalgic
        }
    }
}

public enum CheckInSegment: String, CaseIterable, Sendable {
    case everyone, friends, you
}

public extension CheckIn {
    func getImageUrl(baseUrl: URL) -> URL? {
        guard let image = images.first else { return nil }
        return image.getLogoUrl(baseUrl: baseUrl)
    }
}

public extension CheckIn.Image {
    func getImageUrl(baseUrl: URL) -> URL? {
        guard let image = images.first else { return nil }
        return image.getLogoUrl(baseUrl: baseUrl)
    }
}
