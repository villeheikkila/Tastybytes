import Foundation

struct CheckIn: Identifiable, Hashable {
    let id: Int
    let rating: Double?
    let review: String?
    let createdAt: String
    let profile: Profile
    let product: Product
    let checkInReactions: [CheckInReaction]
    
    static func == (lhs: CheckIn, rhs: CheckIn) -> Bool {
        return lhs.id == rhs.id
    }
}

extension CheckIn: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case rating
        case review
        case createdAt = "created_at"
        case profile = "profiles"
        case product = "products"
        case checkInReactions = "check_in_reactions"
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        rating = try values.decodeIfPresent(Double.self, forKey: .rating)
        review = try values.decodeIfPresent(String.self, forKey: .review)
        createdAt = try values.decode(String.self, forKey: .createdAt)
        profile = try values.decode(Profile.self, forKey: .profile)
        product = try values.decode(Product.self, forKey: .product)
        checkInReactions = try values.decode([CheckInReaction].self, forKey: .checkInReactions)
    }
}

struct NewCheckIn: Encodable {
    let product_id: Int
    let created_by: String
    let rating: Int?
    let review: String?
    
    init (productId: Int, createdBy: UUID, rating: Int?, review: String?) {
        self.rating = rating
        self.review = review
        self.product_id = productId
        self.created_by = createdBy.uuidString.lowercased()
    }
    
}

struct NewCheckInParams: Encodable {
    let p_product_id: Int
    let p_rating: Int?
    let p_review: String?
    let p_manufacturer_id: Int?
    let p_serving_style_id: Int?
    let p_friend_ids: [String]?
    
    init (productId: Int, rating: Int?, review: String?, manufacturerId: Int?, servingStyleId: Int?, friendIds: [UUID]) {
        self.p_product_id = productId
        self.p_rating = rating
        self.p_review = review
        self.p_manufacturer_id = manufacturerId
        self.p_serving_style_id = servingStyleId
        self.p_friend_ids = friendIds.map { $0.uuidString.lowercased() }
    }
    
}

