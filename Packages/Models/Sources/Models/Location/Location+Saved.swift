import CoreLocation
import MapKit
public import Tagged

public extension Location {
    struct Saved: Identifiable, Codable, Hashable, Sendable {
        public let id: Location.Id
        public let mapKitIdentifier: String?
        public let name: String
        public let title: String?
        public let location: CLLocation?
        public let countryCode: String?
        public let country: Country?
        public let source: String

        public init(mapItem: MKMapItem) {
            id = Location.Id(rawValue: UUID())
            mapKitIdentifier = mapItem.identifier?.rawValue
            name = mapItem.name.orEmpty
            title = mapItem.placemark.title.orEmpty
            location = mapItem.placemark.location
            countryCode = mapItem.placemark.countryCode
            country = nil
            source = "apple"
        }

        public init(coordinate: CLLocationCoordinate2D, countryCode: String?, country: Country?) {
            id = Location.Id(rawValue: UUID())
            name = "Lat: \(coordinate.latitude.formatted(.number.precision(.fractionLength(2))))°, Lon: \(coordinate.longitude.formatted(.number.precision(.fractionLength(2))))° \(country?.name ?? "")"
            title = nil
            mapKitIdentifier = nil
            location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.countryCode = countryCode
            self.country = country
            source = "image"
        }

        public init(id: Location.Id, mapKitIdentifier: String?, name: String, title: String?, location: CLLocation?, countryCode: String?,
                    country: Country?, source: String)
        {
            self.id = id
            self.name = name
            self.title = title
            self.location = location
            self.mapKitIdentifier = mapKitIdentifier
            self.countryCode = countryCode
            self.country = country
            self.source = source
        }

        enum CodingKeys: String, CodingKey {
            case id
            case mapKitIdentifier = "map_kit_identifier"
            case name
            case title
            case longitude
            case latitude
            case createdAt = "created_at"
            case countryCode = "country_code"
            case country = "countries"
            case source
            case createdBy = "profiles"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(Location.Id.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            title = try container.decodeIfPresent(String.self, forKey: .title)
            mapKitIdentifier = try container.decodeIfPresent(String.self, forKey: .mapKitIdentifier)
            let longitude = try container.decode(Double.self, forKey: .longitude)
            let latitude = try container.decode(Double.self, forKey: .latitude)
            location = CLLocation(latitude: latitude, longitude: longitude)
            countryCode = try container.decode(String.self, forKey: .countryCode)
            country = try container.decode(Country.self, forKey: .country)
            source = try container.decode(String.self, forKey: .source)
        }

        public init(location: Location.Detailed) {
            id = location.id
            name = location.name
            title = location.title
            self.location = location.location
            mapKitIdentifier = location.mapKitIdentifier
            countryCode = location.countryCode
            country = location.country
            source = location.source
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(title, forKey: .title)
            try container.encode(location?.coordinate.longitude, forKey: .longitude)
            try container.encode(location?.coordinate.latitude, forKey: .latitude)
            try container.encode(countryCode, forKey: .countryCode)
            try container.encode(country, forKey: .country)
        }

        public func copyWith(
            id: Location.Id? = nil,
            mapKitIdentifier: String? = nil,
            name: String? = nil,
            title: String?? = nil,
            location: CLLocation? = nil,
            countryCode: String? = nil,
            country: Country? = nil,
            source: String? = nil
        ) -> Self {
            .init(
                id: id ?? self.id,
                mapKitIdentifier: mapKitIdentifier ?? self.mapKitIdentifier,
                name: name ?? self.name,
                title: title ?? self.title,
                location: location ?? self.location,
                countryCode: countryCode ?? self.countryCode,
                country: country ?? self.country,
                source: source ?? self.source
            )
        }

        public var newLocationRequest: NewLocationRequest {
            NewLocationRequest(location: self)
        }
    }
}
