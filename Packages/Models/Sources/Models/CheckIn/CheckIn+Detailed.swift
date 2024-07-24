import Foundation
public import Tagged

public extension CheckIn {
    struct Detailed: Identifiable, Hashable, Decodable, Sendable, ModificationInfoCascaded {
        public let id: CheckIn.Id
        public let rating: Double?
        public let review: String?
        public let checkInAt: Date?
        public let product: Product.Joined
        public let checkInReactions: [CheckIn.Reaction.Saved]
        public let taggedProfiles: [CheckInTaggedProfile]
        public let flavors: [CheckInFlavor]
        public let variant: Product.Variant.JoinedCompany?
        public let servingStyle: ServingStyle.Saved?
        public let location: Location.Saved?
        public let purchaseLocation: Location.Saved?
        public let images: [ImageEntity.Saved]
        public let isNostalgic: Bool
        public let reports: [Report.Joined]
        public let createdAt: Date
        public let createdBy: Profile.Saved
        public let updatedAt: Date?
        public let updatedBy: Profile.Saved?

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
            checkInReactions: [CheckIn.Reaction.Saved],
            taggedProfiles: [CheckInTaggedProfile],
            flavors: [CheckInFlavor],
            variant: Product.Variant.JoinedCompany? = nil,
            servingStyle: ServingStyle.Saved? = nil,
            location: Location.Saved? = nil,
            purchaseLocation: Location.Saved? = nil,
            images: [ImageEntity.Saved],
            isNostalgic: Bool = false,
            reports: [Report.Joined],
            createdAt: Date,
            createdBy: Profile.Saved,
            updatedAt: Date?,
            updatedBy: Profile.Saved?
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
            checkInReactions: [CheckIn.Reaction.Saved]? = nil,
            taggedProfiles: [CheckInTaggedProfile]? = nil,
            flavors: [CheckInFlavor]? = nil,
            variant: Product.Variant.JoinedCompany? = nil,
            servingStyle: ServingStyle.Saved? = nil,
            location: Location.Saved? = nil,
            purchaseLocation: Location.Saved? = nil,
            isNostalgic: Bool? = nil,
            images: [ImageEntity.Saved]? = nil,
            reports: [Report.Joined]? = nil
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
