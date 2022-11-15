import Foundation

struct CheckIn: Identifiable {
    let id: Int
    let rating: Double?
    let review: String?
    let imageUrl: String?
    let createdAt: Date
    let profile: Profile
    let product: ProductJoined
    let checkInReactions: [CheckInReaction]
    let taggedProfiles: [Profile]
    let flavors: [Flavor]
    let variant: ProductVariant?
    let servingStyle: ServingStyle?
    let location: Location?

    func isEmpty() -> Bool {
        return [rating == nil, (review == nil || review == ""), flavors.count == 0].allSatisfy { $0 }
    }
    
    func getImageUrl() -> URL? {
        if let imageUrl = imageUrl {
            let bucketId = "check-ins"
            let urlString = "\(Config.supabaseUrl)/storage/v1/object/public/\(bucketId)/\(profile.id.uuidString.lowercased())/\(imageUrl)"
            
            guard let url = URL(string: urlString) else { return nil }            
            return url
        } else {
            return nil
        }
    }
    
}

extension CheckIn {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = "check_ins"
        let saved = "id, rating, review, image_url, created_at"
        let checkInTaggedProfilesJoined = "check_in_tagged_profiles (\(Profile.getQuery(.minimal(true))))"
        let productVariantJoined = "product_variants (id, \(Company.getQuery(.saved(true))))"
        let checkInFlavorsJoined = "check_in_flavors (\(Flavor.getQuery(.saved(true))))"
        
        switch queryType {
        case .tableName:
            return tableName
        case let .joined(withTableName):
            return queryWithTableName(tableName, joinWithComma(saved, Profile.getQuery(.minimal(true)), Product.getQuery(.joinedBrandSubcategories(true)), CheckInReaction.getQuery(.joinedProfile(true)), checkInTaggedProfilesJoined, checkInFlavorsJoined, productVariantJoined, ServingStyle.getQuery(.saved(true))), withTableName)
        }
    }
    
    enum QueryType {
        case tableName
        case joined(_ withTableName: Bool)
    }
}

extension CheckIn: Hashable {
    static func == (lhs: CheckIn, rhs: CheckIn) -> Bool {
        return lhs.id == rhs.id && lhs.profile.preferredName == rhs.profile.preferredName
    }
}

extension CheckIn: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case rating
        case review
        case imageUrl = "image_url"
        case createdAt = "created_at"
        case profile = "profiles"
        case product = "products"
        case checkInReactions = "check_in_reactions"
        case taggedProfiles = "check_in_tagged_profiles"
        case flavors = "check_in_flavors"
        case variant = "product_variants"
        case servingStyle = "serving_styles"
        case location = "locations"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        rating = try values.decodeIfPresent(Double.self, forKey: .rating)
        review = try values.decodeIfPresent(String.self, forKey: .review)
        imageUrl = try values.decodeIfPresent(String.self, forKey: .imageUrl)
        createdAt = try parseDate(from: try values.decode(String.self, forKey: .createdAt))
        profile = try values.decode(Profile.self, forKey: .profile)
        product = try values.decode(ProductJoined.self, forKey: .product)
        checkInReactions = try values.decode([CheckInReaction].self, forKey: .checkInReactions)
        taggedProfiles = try values.decode([CheckInTaggedProfile].self, forKey: .taggedProfiles).compactMap { $0.profile }
        flavors = try values.decode([CheckInFlavors].self, forKey: .flavors).compactMap { $0.flavor }
        variant = try values.decodeIfPresent(ProductVariant.self, forKey: .variant)
        servingStyle = try values.decodeIfPresent(ServingStyle.self, forKey: .servingStyle)
        location = try values.decodeIfPresent(Location.self, forKey: .location)
    }
}

struct NewCheckInParams: Encodable {
    let p_product_id: Int
    let p_rating: Double?
    let p_review: String?
    let p_manufacturer_id: Int?
    let p_serving_style_id: Int?
    let p_friend_ids: [String]?
    let p_flavor_ids: [Int]?
    let p_location_id: String?

    
    init(product: ProductJoined, review: String?, taggedFriends: [Profile], servingStyle: ServingStyle?, manufacturer: Company?, flavors: [Flavor], rating: Double, location: Location?) {
        self.p_product_id = product.id
        self.p_review = review == "" ? nil : review
        self.p_manufacturer_id = manufacturer?.id ?? nil
        self.p_serving_style_id = servingStyle?.id ?? nil
        self.p_friend_ids = taggedFriends.map { $0.id.uuidString }
        self.p_flavor_ids = flavors.map { $0.id }
        self.p_rating = rating
        self.p_location_id = location?.id.uuidString
    }
}

struct UpdateCheckInParams: Encodable  {
    let p_check_in_id: Int
    let p_product_id: Int
    let p_rating: Double
    let p_review: String?
    let p_manufacturer_id: Int?
    let p_serving_style_id: Int?
    let p_friend_ids: [String]?
    let p_flavor_ids: [Int]?
    let p_location_id: String?
    
    init(checkIn: CheckIn, product: ProductJoined, review: String?, taggedFriends: [Profile], servingStyle: ServingStyle?, manufacturer: Company?, flavors: [Flavor], rating: Double, location: Location?) {
        self.p_check_in_id = checkIn.id
        self.p_product_id = product.id
        self.p_review = review
        self.p_manufacturer_id = manufacturer?.id ?? nil
        self.p_serving_style_id = servingStyle?.id ?? nil
        self.p_friend_ids = taggedFriends.map { $0.id.uuidString }
        self.p_flavor_ids = flavors.map { $0.id }
        self.p_rating = rating
        self.p_location_id = location?.id.uuidString
    }
}

struct CheckInTaggedProfile: Decodable {
    let profile: Profile
    
    enum CodingKeys: String, CodingKey {
        case profile = "profiles"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        profile = try values.decode(Profile.self, forKey: .profile)
    }
}

struct CheckInFlavors: Decodable {
    let flavor: Flavor
    
    enum CodingKeys: String, CodingKey {
        case flavor = "flavors"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        flavor = try values.decode(Flavor.self, forKey: .flavor)
    }
}

struct CheckInNotification: Identifiable, Hashable, Decodable {
    let id: Int
    let profile: Profile
    let product: ProductJoined
    
    static func == (lhs: CheckInNotification, rhs: CheckInNotification) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case profile = "profiles"
        case product = "products"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        profile = try values.decode(Profile.self, forKey: .profile)
        product = try values.decode(ProductJoined.self, forKey: .product)
    }
}

