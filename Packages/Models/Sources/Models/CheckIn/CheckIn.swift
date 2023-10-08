import Extensions
import Foundation

public struct CheckIn: Identifiable, Hashable, Codable, Sendable {
    public let id: Int
    public let rating: Double?
    public let review: String?
    public let imageFile: String?
    public let checkInAt: Date?
    public let blurHash: BlurHash?
    public let profile: Profile
    public let product: Product.Joined
    public let checkInReactions: [CheckInReaction]
    public let taggedProfiles: [Profile]
    public let flavors: [Flavor]
    public let variant: ProductVariant?
    public let servingStyle: ServingStyle?
    public let location: Location?
    public let purchaseLocation: Location?

    public var isEmpty: Bool {
        [rating == nil, review.isNilOrEmpty, flavors.isEmpty, purchaseLocation == nil].allSatisfy { $0 }
    }

    public init(
        id: Int,
        rating: Double? = nil,
        review: String? = nil,
        imageFile: String? = nil,
        checkInAt: Date? = nil,
        blurHash: CheckIn.BlurHash? = nil,
        profile: Profile,
        product: Product.Joined,
        checkInReactions: [CheckInReaction],
        taggedProfiles: [Profile],
        flavors: [Flavor],
        variant: ProductVariant? = nil,
        servingStyle: ServingStyle? = nil,
        location: Location? = nil,
        purchaseLocation: Location? = nil
    ) {
        self.id = id
        self.rating = rating
        self.review = review
        self.imageFile = imageFile
        self.checkInAt = checkInAt
        self.blurHash = blurHash
        self.profile = profile
        self.product = product
        self.checkInReactions = checkInReactions
        self.taggedProfiles = taggedProfiles
        self.flavors = flavors
        self.variant = variant
        self.servingStyle = servingStyle
        self.location = location
        self.purchaseLocation = purchaseLocation
    }

    public func copyWith(
        rating: Double? = nil,
        review: String? = nil,
        imageFile: String? = nil,
        checkInAt: Date? = nil,
        blurHash: BlurHash? = nil,
        profile: Profile? = nil,
        product: Product.Joined? = nil,
        checkInReactions: [CheckInReaction]? = nil,
        taggedProfiles: [Profile]? = nil,
        flavors: [Flavor]? = nil,
        variant: ProductVariant? = nil,
        servingStyle: ServingStyle? = nil,
        location: Location? = nil,
        purchaseLocation: Location?? = nil
    ) -> CheckIn {
        CheckIn(
            id: id,
            rating: rating ?? self.rating,
            review: review ?? self.review,
            imageFile: imageFile ?? self.imageFile,
            checkInAt: checkInAt ?? self.checkInAt,
            blurHash: blurHash ?? self.blurHash,
            profile: profile ?? self.profile,
            product: product ?? self.product,
            checkInReactions: checkInReactions ?? self.checkInReactions,
            taggedProfiles: taggedProfiles ?? self.taggedProfiles,
            flavors: flavors ?? self.flavors,
            variant: variant ?? self.variant,
            servingStyle: servingStyle ?? self.servingStyle,
            location: location ?? self.location,
            purchaseLocation: purchaseLocation ?? self.purchaseLocation
        )
    }

    enum CodingKeys: String, CodingKey {
        case id
        case rating
        case review
        case blurHash = "blur_hash"
        case imageFile = "image_file"
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
    }

    public init(from decoder: Decoder) throws {
        struct CheckInTaggedProfile: Codable {
            let profile: Profile
            enum CodingKeys: String, CodingKey {
                case profile = "profiles"
            }
        }

        struct CheckInFlavors: Codable {
            let flavor: Flavor
            enum CodingKeys: String, CodingKey {
                case flavor = "flavors"
            }
        }

        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        rating = try values.decodeIfPresent(Double.self, forKey: .rating)
        review = try values.decodeIfPresent(String.self, forKey: .review)
        imageFile = try values.decodeIfPresent(String.self, forKey: .imageFile)
        let blurHashString = try values.decodeIfPresent(String.self, forKey: .blurHash)
        if let blurHashString {
            blurHash = try BlurHash(str: blurHashString)
        } else {
            blurHash = nil
        }
        let checkInAtString = try values.decodeIfPresent(String.self, forKey: .checkInAt)
        if let checkInAtString {
            checkInAt = Date(timestamptzString: checkInAtString)
        } else {
            checkInAt = nil
        }
        profile = try values.decode(Profile.self, forKey: .profile)
        product = try values.decode(Product.Joined.self, forKey: .product)
        checkInReactions = try values.decode([CheckInReaction].self, forKey: .checkInReactions)
        taggedProfiles = try values.decode([CheckInTaggedProfile].self, forKey: .taggedProfiles).map(\.profile)
        flavors = try values.decode([CheckInFlavors].self, forKey: .flavors).map(\.flavor)
        variant = try values.decodeIfPresent(ProductVariant.self, forKey: .variant)
        servingStyle = try values.decodeIfPresent(ServingStyle.self, forKey: .servingStyle)
        location = try values.decodeIfPresent(Location.self, forKey: .location)
        purchaseLocation = try values.decodeIfPresent(Location.self, forKey: .purchaseLocation)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encodeIfPresent(review, forKey: .review)
        try container.encodeIfPresent(imageFile, forKey: .imageFile)
        try container.encodeIfPresent(blurHash?.encoded, forKey: .blurHash)
        if let checkInAt {
            let checkInAtString = CustomDateFormatter.shared.format(date: checkInAt, .timestampTz)
            try container.encode(checkInAtString, forKey: .checkInAt)
        }
        try container.encode(profile, forKey: .profile)
        try container.encode(product, forKey: .product)
        try container.encode(checkInReactions, forKey: .checkInReactions)
        try container.encode(taggedProfiles, forKey: .taggedProfiles)
        try container.encode(flavors, forKey: .flavors)
        try container.encodeIfPresent(variant, forKey: .variant)
        try container.encodeIfPresent(servingStyle, forKey: .servingStyle)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(purchaseLocation, forKey: .purchaseLocation)
    }
}

public extension CheckIn {
    struct CheckInTaggedProfile: Codable {
        let profile: Profile

        enum CodingKeys: String, CodingKey {
            case profile = "profiles"
        }
    }

    struct CheckInFlavors: Codable {
        let flavor: Flavor

        enum CodingKeys: String, CodingKey {
            case flavor = "flavors"
        }
    }

    struct Image: Hashable, Sendable, Identifiable, Codable {
        public let id: Int
        public let createdBy: UUID
        public let imageFile: String?
        public let blurHash: BlurHash?

        enum CodingKeys: String, CodingKey {
            case id
            case blurHash = "blur_hash"
            case imageFile = "image_file"
            case createdBy = "created_by"
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(Int.self, forKey: .id)
            createdBy = try values.decode(UUID.self, forKey: .createdBy)
            imageFile = try values.decodeIfPresent(String.self, forKey: .imageFile)
            let blurHashString = try values.decodeIfPresent(String.self, forKey: .blurHash)
            if let blurHashString {
                blurHash = try BlurHash(str: blurHashString)
            } else {
                blurHash = nil
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(createdBy, forKey: .createdBy)
            try container.encodeIfPresent(imageFile, forKey: .imageFile)
            try container.encodeIfPresent(blurHash?.encoded, forKey: .blurHash)
        }
    }

    struct BlurHash: Hashable, Sendable {
        enum BlurHashError: Error {
            case genericError
        }

        public let hash: String
        public let height: Double
        public let width: Double

        public init(hash: String, height: Double, width: Double) {
            self.hash = hash
            self.height = height
            self.width = width
        }

        public init(str: String) throws {
            let components = str.components(separatedBy: ":::")
            guard let dimensions = components.first?.components(separatedBy: ":")
            else { throw BlurHashError.genericError }
            guard let width = Double(dimensions[0]) else { throw BlurHashError.genericError }
            guard let height = Double(dimensions[1]) else { throw BlurHashError.genericError }
            let hash = components[1]

            self.hash = hash
            self.width = width
            self.height = height
        }

        public var encoded: String {
            "\(width):\(height):::\(hash)"
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
        public let blurHash: String?
        public let manufacturerId: Int?
        public let servingStyleId: Int?
        public let friendIds: [String]?
        public let flavorIds: [Int]?
        public let locationId: String?
        public let purchaseLocationId: String?
        public let checkInAt: String?

        enum CodingKeys: String, CodingKey {
            case productId = "p_product_id"
            case rating = "p_rating"
            case review = "p_review"
            case blurHash = "p_blur_hash"
            case manufacturerId = "p_manufacturer_id"
            case servingStyleId = "p_serving_style_id"
            case friendIds = "p_friend_ids"
            case flavorIds = "p_flavor_ids"
            case locationId = "p_location_id"
            case purchaseLocationId = "p_purchase_location_id"
            case checkInAt = "p_check_in_at"
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
            blurHash: String?,
            checkInAt: Date?
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
            self.blurHash = blurHash
            if let checkInAt {
                self.checkInAt = checkInAt.customFormat(.timestampTz)
            } else {
                self.checkInAt = nil
            }
        }
    }

    struct UpdateRequest: Codable, Sendable {
        public let checkInId: Int
        public let productId: Int
        public let rating: Double?
        public let review: String?
        public let blurHash: String?
        public let manufacturerId: Int?
        public let servingStyleId: Int?
        public let friendIds: [String]?
        public let flavorIds: [Int]?
        public let locationId: String?
        public let purchaseLocationId: String?
        public let checkInAt: String?

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
            case blurHash = "p_blur_hash"
            case checkInAt = "p_check_in_at"
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
            blurHash: String?,
            checkInAt: Date?
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
            self.blurHash = blurHash
            if let checkInAt {
                self.checkInAt = checkInAt.customFormat(.timestampTz)
            } else {
                self.checkInAt = nil
            }
        }
    }
}

public enum CheckInSegment: String, CaseIterable {
    case everyone, friends, you
}

public extension CheckIn {
    var imageUrl: URL? {
        guard let imageFile else { return nil }
        return URL(
            bucket: .checkIns,
            fileName: "\(profile.id.uuidString.lowercased())/\(imageFile)"
        )
    }
}

public extension CheckIn.Image {
    var imageUrl: URL? {
        guard let imageFile else { return nil }
        return URL(
            bucket: .checkIns,
            fileName: "\(createdBy.uuidString.lowercased())/\(imageFile)"
        )
    }
}
