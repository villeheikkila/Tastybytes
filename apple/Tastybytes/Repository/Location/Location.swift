@preconcurrency import MapKit

struct Location: Identifiable, Codable, Hashable, Sendable {
  let id: UUID
  let name: String
  let title: String?
  let location: CLLocation?
  let countryCode: String?
  let country: Country?

  init(mapItem: MKMapItem) {
    id = UUID()
    name = mapItem.name.orEmpty
    title = mapItem.placemark.title.orEmpty
    location = mapItem.placemark.location
    countryCode = mapItem.placemark.countryCode
    country = nil
  }

  init(id: UUID, name: String, title: String?, location: CLLocation?, countryCode: String?, country: Country?) {
    self.id = id
    self.name = name
    self.title = title
    self.location = location
    self.countryCode = countryCode
    self.country = country
  }

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case title
    case longitude
    case latitude
    case createdAt = "created_at"
    case countryCode = "country_code"
    case country = "countries"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(UUID.self, forKey: .id)
    name = try container.decode(String.self, forKey: .name)
    title = try container.decodeIfPresent(String.self, forKey: .title)
    let longitude = try container.decode(Double.self, forKey: .longitude)
    let latitude = try container.decode(Double.self, forKey: .latitude)
    location = CLLocation(latitude: latitude, longitude: longitude)
    countryCode = try container.decode(String.self, forKey: .countryCode)
    country = try container.decode(Country.self, forKey: .country)
  }

  enum EncodingKeys: String, CodingKey {
    case name = "p_name", title = "p_title", longitude = "p_longitude", latitude = "p_latitude",
         countryCode = "p_country_code"
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: EncodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(title, forKey: .title)
    try container.encode(location?.coordinate.latitude, forKey: .latitude)
    try container.encode(location?.coordinate.longitude, forKey: .longitude)
    try container.encode(countryCode, forKey: .countryCode)
  }
}

extension Location {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "locations"
    let saved = "id, name, title, longitude, latitude, country_code"

    switch queryType {
    case .tableName:
      return tableName
    case let .joined(withTableName):
      return queryWithTableName(tableName, [saved, Country.getQuery(.saved(true))].joinComma(), withTableName)
    }
  }

  enum QueryType {
    case tableName
    case joined(_ withTableName: Bool)
  }
}

extension Location {
  struct MergeLocationParams: Codable, Sendable {
    let locationId: UUID
    let toLocationId: UUID

    enum CodingKeys: String, CodingKey {
      case locationId = "p_location_id", toLocationId = "p_to_location_id"
    }
  }

  struct SuggestionParams: Codable, Sendable {
    let longitude: Double
    let latitude: Double

    enum CodingKeys: String, CodingKey {
      case longitude = "p_longitude", latitude = "p_latitude"
    }

    init(location: CLLocation) {
      latitude = location.coordinate.latitude
      longitude = location.coordinate.longitude
    }
  }

  struct New: Codable, Sendable {
    let name: String
    let title: String?
    let longitude: Double
    let latitude: Double
    let countryCode: String

    enum CodingKeys: String, CodingKey {
      case name = "p_name", title = "p_title", longitude = "p_longitude", latitude = "p_latitude",
           countryCode = "p_country_code"
    }
  }

  struct SummaryRequest: Codable, Sendable {
    let id: UUID

    enum CodingKeys: String, CodingKey {
      case id = "p_location_id"
    }
  }
}
