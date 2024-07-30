import Foundation
public import Tagged

public extension CheckIn {
    struct CheckInTaggedProfile: Codable, Sendable, Hashable {
        public let profile: Profile.Saved

        enum CodingKeys: String, CodingKey {
            case profile = "profiles"
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
            taggedFriends: [Profile.Saved],
            servingStyle: ServingStyle.Saved?,
            manufacturer: Company.Saved?,
            flavors: [Flavor.Saved],
            rating: Double,
            location: Location.Saved?,
            purchaseLocation: Location.Saved?,
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
            checkIn: CheckIn.Joined,
            product: Product.Joined,
            review: String?,
            taggedFriends: [Profile.Saved],
            servingStyle: ServingStyle.Saved?,
            manufacturer: Company.Saved?,
            flavors: [Flavor.Saved],
            rating: Double,
            location: Location.Saved?,
            purchaseLocation: Location.Saved?,
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
