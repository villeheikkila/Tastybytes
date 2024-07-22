import Extensions
import Foundation
import Tagged

public struct CheckIn: Identifiable, Hashable, Codable, Sendable {
    public let id: CheckIn.Id
    public let rating: Double?
    public let review: String?
    public let checkInAt: Date?
    public let profile: Profile
    public let product: Product.Joined
    public let checkInReactions: [CheckInReaction]
    public let taggedProfiles: [CheckInTaggedProfile]
    public let flavors: [CheckInFlavor]
    public let variant: Product.Variant?
    public let servingStyle: ServingStyle?
    public let location: Location?
    public let purchaseLocation: Location?
    public let images: [ImageEntity]
    public let isNostalgic: Bool

    public init(
        id: CheckIn.Id,
        rating: Double? = nil,
        review: String? = nil,
        checkInAt: Date? = nil,
        profile: Profile,
        product: Product.Joined,
        checkInReactions: [CheckInReaction],
        taggedProfiles: [CheckInTaggedProfile],
        flavors: [CheckInFlavor],
        variant: Product.Variant? = nil,
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
        profile: Profile? = nil,
        product: Product.Joined? = nil,
        checkInReactions: [CheckInReaction]? = nil,
        taggedProfiles: [CheckInTaggedProfile]? = nil,
        flavors: [CheckInFlavor]? = nil,
        variant: Product.Variant? = nil,
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
    struct Detailed: Identifiable, Hashable, Decodable, Sendable, ModificationInfoCascaded {
        public let id: CheckIn.Id
        public let rating: Double?
        public let review: String?
        public let checkInAt: Date?
        public let product: Product.Joined
        public let checkInReactions: [CheckInReaction]
        public let taggedProfiles: [CheckInTaggedProfile]
        public let flavors: [CheckInFlavor]
        public let variant: Product.Variant?
        public let servingStyle: ServingStyle?
        public let location: Location?
        public let purchaseLocation: Location?
        public let images: [ImageEntity]
        public let isNostalgic: Bool
        public let reports: [Report]
        public let createdAt: Date
        public let createdBy: Profile
        public let updatedAt: Date?
        public let updatedBy: Profile?

        enum CodingKeys: String, CodingKey {
            case id
            case rating
            case review
            case checkInAt = "check_in_at"
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
            case reports
            case createdAt = "created_at"
            case createdBy = "created_by"
            case updatedAt = "updated_at"
            case updatedBy = "updated_by"
        }

        public init(
            id: CheckIn.Id,
            rating: Double? = nil,
            review: String? = nil,
            checkInAt: Date? = nil,
            product: Product.Joined,
            checkInReactions: [CheckInReaction],
            taggedProfiles: [CheckInTaggedProfile],
            flavors: [CheckInFlavor],
            variant: Product.Variant? = nil,
            servingStyle: ServingStyle? = nil,
            location: Location? = nil,
            purchaseLocation: Location? = nil,
            images: [ImageEntity],
            isNostalgic: Bool = false,
            reports: [Report],
            createdAt: Date,
            createdBy: Profile,
            updatedAt: Date?,
            updatedBy: Profile?
        ) {
            self.id = id
            self.rating = rating
            self.review = review
            self.checkInAt = checkInAt
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
            self.reports = reports
            self.createdAt = createdAt
            self.createdBy = createdBy
            self.updatedAt = updatedAt
            self.updatedBy = updatedBy
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
            reports = []
            createdAt = Date.now
            createdBy = .init()
            updatedAt = nil
            updatedBy = nil
        }

        public func copyWith(
            rating: Double? = nil,
            review: String? = nil,
            checkInAt: Date? = nil,
            product: Product.Joined? = nil,
            checkInReactions: [CheckInReaction]? = nil,
            taggedProfiles: [CheckInTaggedProfile]? = nil,
            flavors: [CheckInFlavor]? = nil,
            variant: Product.Variant? = nil,
            servingStyle: ServingStyle? = nil,
            location: Location? = nil,
            purchaseLocation: Location? = nil,
            isNostalgic: Bool? = nil,
            images: [ImageEntity]? = nil,
            reports: [Report]? = nil
        ) -> Self {
            .init(
                id: id,
                rating: rating ?? self.rating,
                review: review ?? self.review,
                checkInAt: checkInAt ?? self.checkInAt,
                product: product ?? self.product,
                checkInReactions: checkInReactions ?? self.checkInReactions,
                taggedProfiles: taggedProfiles ?? self.taggedProfiles,
                flavors: flavors ?? self.flavors,
                variant: variant ?? self.variant,
                servingStyle: servingStyle ?? self.servingStyle,
                location: location ?? self.location,
                purchaseLocation: purchaseLocation ?? self.purchaseLocation,
                images: images ?? self.images,
                isNostalgic: isNostalgic ?? self.isNostalgic,
                reports: reports ?? self.reports,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy
            )
        }
    }
}

public extension CheckIn {
    typealias Id = Tagged<CheckIn, Int>
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

    struct Minimal: Codable, Hashable, Sendable, Identifiable {
        public let id: CheckIn.Id
        public let createdBy: Profile.Id

        enum CodingKeys: String, CodingKey {
            case id
            case createdBy = "created_by"
        }
    }

    struct DeleteAsAdminRequest: Codable, Sendable {
        public let id: CheckIn.Id

        public init(id: CheckIn.Id) {
            self.id = id
        }

        enum CodingKeys: String, CodingKey {
            case id = "p_check_in_id"
        }
    }

    struct NewRequest: Codable, Sendable {
        public let productId: Product.Id
        public let rating: Double?
        public let review: String?
        public let manufacturerId: Company.Id?
        public let servingStyleId: ServingStyle.Id?
        public let friendIds: [String]?
        public let flavorIds: [Flavor.Id]?
        public let locationId: Location.Id?
        public let purchaseLocationId: Location.Id?
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
            locationId = location?.id
            purchaseLocationId = purchaseLocation?.id
            self.checkInAt = checkInAt
            self.isNostalgic = isNostalgic
        }
    }

    struct UpdateRequest: Codable, Sendable {
        public let checkInId: CheckIn.Id
        public let productId: Product.Id
        public let rating: Double?
        public let review: String?
        public let manufacturerId: Company.Id?
        public let servingStyleId: ServingStyle.Id?
        public let friendIds: [String]?
        public let flavorIds: [Flavor.Id]?
        public let locationId: Location.Id?
        public let purchaseLocationId: Location.Id?
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
            locationId = location?.id
            purchaseLocationId = purchaseLocation?.id
            self.checkInAt = checkInAt
            self.isNostalgic = isNostalgic
        }
    }
}

public enum CheckInSegment: String, CaseIterable, Sendable {
    case everyone, friends, you
}
