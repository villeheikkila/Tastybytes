import CoreLocation
import MapKit
public import Tagged

public extension Location {
    struct Detailed: Identifiable, Decodable, Hashable, Sendable, ModificationInfo {
        public let id: Location.Id
        public let mapKitIdentifier: String?
        public let name: String
        public let title: String?
        public let location: CLLocation?
        public let countryCode: String?
        public let country: Country?
        public let source: String
        public let reports: [Report.Joined]
        public let createdAt: Date
        public let createdBy: Profile?
        public let updatedBy: Profile?
        public let updatedAt: Date?

        enum CodingKeys: String, CodingKey {
            case id
            case mapKitIdentifier = "map_kit_identifier"
            case name
            case title
            case longitude
            case latitude
            case countryCode = "country_code"
            case country = "countries"
            case source
            case reports
            case createdBy = "created_by"
            case createdAt = "created_at"
            case updatedBy = "updated_by"
            case updatedAt = "updated_at"
        }

        public init(
            id: Location.Id,
            mapKitIdentifier: String?,
            name: String,
            title: String?,
            location: CLLocation?,
            countryCode: String?,
            country: Country?,
            source: String,
            reports: [Report.Joined],
            createdAt: Date,
            createdBy: Profile?,
            updatedBy: Profile?,
            updatedAt: Date?
        ) {
            self.id = id
            self.name = name
            self.title = title
            self.location = location
            self.mapKitIdentifier = mapKitIdentifier
            self.countryCode = countryCode
            self.country = country
            self.source = source
            self.reports = reports
            self.createdAt = createdAt
            self.createdBy = createdBy
            self.updatedBy = updatedBy
            self.updatedAt = updatedAt
        }

        public init() {
            id = Location.Id(rawValue: UUID())
            mapKitIdentifier = nil
            name = ""
            title = nil
            location = nil
            countryCode = nil
            country = nil
            source = ""
            reports = []
            createdAt = Date.now
            createdBy = nil
            updatedBy = nil
            updatedAt = nil
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
            reports = try container.decode([Report.Joined].self, forKey: .reports)
            createdBy = try container.decodeIfPresent(Profile.self, forKey: .createdBy)
            createdAt = try container.decode(Date.self, forKey: .createdAt)
            updatedBy = try container.decodeIfPresent(Profile.self, forKey: .updatedBy)
            updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        }

        public func copyWith(
            id: Location.Id? = nil,
            mapKitIdentifier: String? = nil,
            name: String? = nil,
            title: String?? = nil,
            location: CLLocation? = nil,
            countryCode: String? = nil,
            country: Country? = nil,
            source: String? = nil,
            reports: [Report.Joined]? = nil
        ) -> Self {
            .init(
                id: id ?? self.id,
                mapKitIdentifier: mapKitIdentifier ?? self.mapKitIdentifier,
                name: name ?? self.name,
                title: title ?? self.title,
                location: location ?? self.location,
                countryCode: countryCode ?? self.countryCode,
                country: country ?? self.country,
                source: source ?? self.source,
                reports: reports ?? self.reports,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedBy: updatedBy,
                updatedAt: updatedAt
            )
        }
    }
}
