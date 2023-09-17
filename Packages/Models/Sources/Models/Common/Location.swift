import MapKit

public struct Location: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let title: String?
    public let location: CLLocation?
    public let countryCode: String?
    public let country: Country?

    public init(mapItem: MKMapItem) {
        id = UUID()
        name = mapItem.name.orEmpty
        title = mapItem.placemark.title.orEmpty
        location = mapItem.placemark.location
        countryCode = mapItem.placemark.countryCode
        country = nil
    }

    public init(id: UUID, name: String, title: String?, location: CLLocation?, countryCode: String?,
                country: Country?)
    {
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

    public init(from decoder: Decoder) throws {
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

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(title, forKey: .title)
        try container.encode(location?.coordinate.latitude, forKey: .latitude)
        try container.encode(location?.coordinate.longitude, forKey: .longitude)
        try container.encode(countryCode, forKey: .countryCode)
    }
}

public extension Location {
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

    enum RecentLocation {
        case checkIn
        case purchase

        public var view: Database.Table {
            switch self {
            case .checkIn:
                .viewRecentLocationsFromCurrentUser
            case .purchase:
                .viewRecentPurchaseLocationsFromCurrentUser
            }
        }
    }
}
