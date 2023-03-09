import Foundation

struct CheckIn: Identifiable, Hashable, Decodable, Sendable {
  let id: Int
  let rating: Double?
  let review: String?
  let imageFile: String?
  let checkInAt: Date?
  let blurHash: BlurHash?
  let profile: Profile
  let product: Product.Joined
  let checkInReactions: [CheckInReaction]
  let taggedProfiles: [Profile]
  let flavors: [Flavor]
  let variant: ProductVariant?
  let servingStyle: ServingStyle?
  let location: Location?

  var isEmpty: Bool {
    [rating == nil, review.isNilOrEmpty, flavors.isEmpty].allSatisfy { $0 }
  }

  func getImageUrl() -> URL? {
    if let imageFile {
      let bucketId = "check-ins"
      let urlString =
        "\(Config.supabaseUrl)/storage/v1/object/public/\(bucketId)/\(profile.id.uuidString.lowercased())/\(imageFile)"

      return URL(string: urlString)
    } else {
      return nil
    }
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
  }

  init(from decoder: Decoder) throws {
    struct CheckInTaggedProfile: Decodable {
      let profile: Profile
      enum CodingKeys: String, CodingKey {
        case profile = "profiles"
      }
    }

    struct CheckInFlavors: Decodable {
      let flavor: Flavor
      enum CodingKeys: String, CodingKey {
        case flavor = "flavors"
      }
    }

    func decodeBlurHash(_ str: String) -> BlurHash? {
      let components = str.components(separatedBy: ":::")
      guard let dimensions = components.first?.components(separatedBy: ":") else { return nil }
      guard let width = Double(dimensions[0]) else { return nil }
      guard let height = Double(dimensions[1]) else { return nil }
      let hash = components[1]
      return BlurHash(hash: hash, height: height, width: width)
    }

    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(Int.self, forKey: .id)
    rating = try values.decodeIfPresent(Double.self, forKey: .rating)
    review = try values.decodeIfPresent(String.self, forKey: .review)
    imageFile = try values.decodeIfPresent(String.self, forKey: .imageFile)
    let blurHashString = try values.decodeIfPresent(String.self, forKey: .blurHash)
    if let blurHashString {
      blurHash = decodeBlurHash(blurHashString)
    } else {
      blurHash = nil
    }
    let checkInAtString = try values.decodeIfPresent(String.self, forKey: .checkInAt)
    if let checkInAtString {
      checkInAt = try parseDate(from: checkInAtString)
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
  }
}

extension CheckIn {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "check_ins"
    let saved = "id, rating, review, image_file, check_in_at, is_migrated, blur_hash"
    let checkInTaggedProfilesJoined = "check_in_tagged_profiles (\(Profile.getQuery(.minimal(true))))"
    let productVariantJoined = "product_variants (id, \(Company.getQuery(.saved(true))))"
    let checkInFlavorsJoined = "check_in_flavors (\(Flavor.getQuery(.saved(true))))"

    switch queryType {
    case .tableName:
      return tableName
    case let .joined(withTableName):
      return queryWithTableName(
        tableName,
        joinWithComma(saved, Profile.getQuery(.minimal(true)), Product.getQuery(.joinedBrandSubcategories(true)),
                      CheckInReaction.getQuery(.joinedProfile(true)), checkInTaggedProfilesJoined, checkInFlavorsJoined,
                      productVariantJoined, ServingStyle.getQuery(.saved(true)), Location.getQuery(.joined(true))),
        withTableName
      )
    }
  }

  enum QueryType {
    case tableName
    case joined(_ withTableName: Bool)
  }
}

extension CheckIn {
  struct BlurHash: Hashable, Sendable {
    let hash: String
    let height: Double
    let width: Double
  }

  struct NewRequest: Encodable, Sendable {
    let productId: Int
    let rating: Double?
    let review: String?
    let blurHash: String?
    let manufacturerId: Int?
    let servingStyleId: Int?
    let friendIds: [String]?
    let flavorIds: [Int]?
    let locationId: String?

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
    }

    init(
      product: Product.Joined,
      review: String?,
      taggedFriends: [Profile],
      servingStyle: ServingStyle?,
      manufacturer: Company?,
      flavors: [Flavor],
      rating: Double,
      location: Location?,
      blurHash: String?
    ) {
      productId = product.id
      self.review = review.isNilOrEmpty ? nil : review
      manufacturerId = manufacturer?.id
      servingStyleId = servingStyle?.id
      friendIds = taggedFriends.map(\.id.uuidString)
      flavorIds = flavors.map(\.id)
      self.rating = rating
      locationId = location?.id.uuidString
      self.blurHash = blurHash
    }
  }

  struct UpdateRequest: Encodable, Sendable {
    let checkInId: Int
    let productId: Int
    let rating: Double?
    let review: String?
    let blurHash: String?
    let manufacturerId: Int?
    let servingStyleId: Int?
    let friendIds: [String]?
    let flavorIds: [Int]?
    let locationId: String?

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
      case blurHash = "p_blur_hash"
    }

    init(
      checkIn: CheckIn,
      product: Product.Joined,
      review: String?,
      taggedFriends: [Profile],
      servingStyle: ServingStyle?,
      manufacturer: Company?,
      flavors: [Flavor],
      rating: Double,
      location: Location?,
      blurHash: String?
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
      self.blurHash = blurHash
    }
  }
}
