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
        name = mapItem.name ?? ""
        title = mapItem.placemark.title ?? ""
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
}

extension Location: Hashable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id
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
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(title, forKey: .title)
        try container.encode(location?.coordinate.latitude, forKey: .latitude)
        try container.encode(location?.coordinate.longitude, forKey: .longitude)
        try container.encode(countryCode, forKey: .countryCode)
    }
}
