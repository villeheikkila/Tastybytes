public import Tagged
import CoreLocation

public extension Profile {
    struct TopLocations: Sendable, Decodable, Identifiable {
        public let id: Location.Id
        public let name: String
        public let title: String?
        public let location: CLLocation?
        public let countryCode: String?
        public let count: Int

        enum CodingKeys: String, CodingKey {
            case count = "check_ins_count"
            case id
            case name
            case title
            case countryCode = "country_code"
            case source
            case longitude
            case latitude
        }

        public var loc: Location.Saved {
            .init(id: id, mapKitIdentifier: nil, name: name, title: title, location: location, countryCode: countryCode, country: nil, source: "")
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(Location.Id.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            title = try container.decodeIfPresent(String.self, forKey: .title)
            let longitude = try container.decode(Double.self, forKey: .longitude)
            let latitude = try container.decode(Double.self, forKey: .latitude)
            location = CLLocation(latitude: latitude, longitude: longitude)
            countryCode = try container.decode(String.self, forKey: .countryCode)
            count = try container.decode(Int.self, forKey: .count)
        }
    }
}
