import CoreLocation
import Foundation

public extension Location {
    struct NewLocationRequest: Encodable, Hashable, Sendable {
        public let name: String
        public let title: String?
        public let location: CLLocation?
        public let countryCode: String?
        public let country: Country.Saved?
        public let mapKitIdentifier: String?

        public init(location: Location.Saved) {
            name = location.name
            title = location.title
            self.location = location.location
            countryCode = location.countryCode
            country = location.country
            mapKitIdentifier = location.mapKitIdentifier
        }

        enum EncodingKeys: String, CodingKey {
            case name = "p_name", title = "p_title", longitude = "p_longitude", latitude = "p_latitude",
                 countryCode = "p_country_code", mapKitIdentifier = "p_map_kit_identifier"
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: EncodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(title, forKey: .title)
            try container.encode(location?.coordinate.latitude, forKey: .latitude)
            try container.encode(location?.coordinate.longitude, forKey: .longitude)
            try container.encode(countryCode, forKey: .countryCode)
            try container.encode(mapKitIdentifier, forKey: .mapKitIdentifier)
        }
    }

    struct UpdateLocationRequest: Codable, Sendable {
        let id: Location.Id
        let mapKitIdentifier: String?

        public init(id: Location.Id, mapKitIdentifier: String?) {
            self.id = id
            self.mapKitIdentifier = mapKitIdentifier
        }

        enum CodingKeys: String, CodingKey {
            case id = "p_id", mapKitIdentifier = "p_map_kit_identifier"
        }
    }

    struct MergeLocationParams: Codable, Sendable {
        public init(locationId: Location.Id, toLocationId: Location.Id) {
            self.locationId = locationId
            self.toLocationId = toLocationId
        }

        let locationId: Location.Id
        let toLocationId: Location.Id

        enum CodingKeys: String, CodingKey {
            case locationId = "p_location_id", toLocationId = "p_to_location_id"
        }
    }

    struct SuggestionParams: Codable, Sendable {
        public let longitude: Double
        public let latitude: Double

        enum CodingKeys: String, CodingKey {
            case longitude = "p_longitude", latitude = "p_latitude"
        }

        public init(location: CLLocation) {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
        }

        public init(coordinate: CLLocationCoordinate2D) {
            latitude = coordinate.latitude
            longitude = coordinate.longitude
        }
    }

    struct SummaryRequest: Codable, Sendable {
        public init(id: Location.Id) {
            self.id = id
        }

        public let id: Location.Id

        enum CodingKeys: String, CodingKey {
            case id = "p_location_id"
        }
    }

    enum RecentLocation: Sendable {
        case checkIn
        case purchase
    }
}
