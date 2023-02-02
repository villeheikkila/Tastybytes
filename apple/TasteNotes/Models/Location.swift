import Foundation
import MapKit

struct Location: Identifiable {
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

  func getNew() -> New? {
    // TODO: Encodable should be good enough for this
    if let location, let countryCode {
      return New(
        name: name,
        title: title,
        longitude: location.coordinate.longitude,
        latitude: location.coordinate.latitude,
        countryCode: countryCode
      )
    } else {
      return nil
    }
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
      return queryWithTableName(tableName, joinWithComma(saved, Country.getQuery(.saved(true))), withTableName)
    }
  }

  enum QueryType {
    case tableName
    case joined(_ withTableName: Bool)
  }
}

extension Location: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Location, rhs: Location) -> Bool {
    lhs.id == rhs.id
  }
}

extension Location: Decodable {
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
}

extension Location: Encodable {
  enum EncodableCodingKeys: String, CodingKey {
    case name = "p_name"
    case title = "p_title"
    case longitude = "p_longitude"
    case latitude = "p_latitude"
    case countryCode = "p_country_code"
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: EncodableCodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(title, forKey: .title)
    try container.encode(location?.coordinate.latitude, forKey: .latitude)
    try container.encode(location?.coordinate.longitude, forKey: .longitude)
    try container.encode(countryCode, forKey: .countryCode)
  }
}

extension Location {
  struct New: Encodable {
    let p_name: String
    let p_title: String?
    let p_longitude: Double
    let p_latitude: Double
    let p_country_code: String

    init(name: String, title: String?, longitude: Double, latitude: Double, countryCode: String) {
      p_name = name
      p_title = title
      p_longitude = longitude
      p_latitude = latitude
      p_country_code = countryCode
    }
  }

  struct SummaryRequest: Encodable {
    let p_location_id: UUID

    init(id: UUID) {
      p_location_id = id
    }
  }
}
