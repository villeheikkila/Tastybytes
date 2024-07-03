import CoreLocation
import MapKit

public struct Location: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let mapKitIdentifier: String?
    public let name: String
    public let title: String?
    public let location: CLLocation?
    public let countryCode: String?
    public let country: Country?
    public let source: String

    public init(mapItem: MKMapItem) {
        id = UUID()
        mapKitIdentifier = mapItem.identifier?.rawValue
        name = mapItem.name.orEmpty
        title = mapItem.placemark.title.orEmpty
        location = mapItem.placemark.location
        countryCode = mapItem.placemark.countryCode
        country = nil
        source = "apple"
    }

    public init(coordinate: CLLocationCoordinate2D, countryCode: String?, country: Country?) {
        id = UUID()
        name = "Lat: \(coordinate.latitude.formatted(.number.precision(.fractionLength(2))))°, Lon: \(coordinate.longitude.formatted(.number.precision(.fractionLength(2))))° \(country?.name ?? "")"
        title = nil
        mapKitIdentifier = nil
        location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.countryCode = countryCode
        self.country = country
        source = "image"
    }

    public init(id: UUID, mapKitIdentifier: String?, name: String, title: String?, location: CLLocation?, countryCode: String?,
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
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
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
        id: UUID? = nil,
        mapKitIdentifier: String? = nil,
        name: String? = nil,
        title: String?? = nil,
        location: CLLocation? = nil,
        countryCode: String? = nil,
        country: Country? = nil,
        source: String? = nil
    ) -> Location {
        Location(
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

public extension Location {
    struct NewLocationRequest: Identifiable, Encodable, Hashable, Sendable {
        public let id: UUID
        public let name: String
        public let title: String?
        public let location: CLLocation?
        public let countryCode: String?
        public let country: Country?
        public let mapKitIdentifier: String?

        public init(location: Location) {
            id = location.id
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
        let id: UUID
        let mapKitIdentifier: String?

        public init(id: UUID, mapKitIdentifier: String?) {
            self.id = id
            self.mapKitIdentifier = mapKitIdentifier
        }

        enum CodingKeys: String, CodingKey {
            case id = "p_id", mapKitIdentifier = "p_map_kit_identifier"
        }
    }

    struct MergeLocationParams: Codable, Sendable {
        public init(locationId: UUID, toLocationId: UUID) {
            self.locationId = locationId
            self.toLocationId = toLocationId
        }

        let locationId: UUID
        let toLocationId: UUID

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
        public init(id: UUID) {
            self.id = id
        }

        public let id: UUID

        enum CodingKeys: String, CodingKey {
            case id = "p_location_id"
        }
    }

    enum RecentLocation: Sendable {
        case checkIn
        case purchase
    }
}

public extension Location {
    struct Formatter<Output> {
        let format: (Location) -> Output
    }

    func formatted<Output>(_ formatter: Formatter<Output>) -> Output {
        formatter.format(self)
    }
}

public extension Location.Formatter where Output == String {
    static var withEmoji: Self {
        .init { value in
            "\(value.name) \(value.country?.emoji ?? "")"
        }
    }
}
