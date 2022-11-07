import Foundation
import MapKit

struct Location: Identifiable {
    let id: UUID
    let name: String
    let title: String
    let location: CLLocation?
    let countryCode: String?

    init(mapItem: MKMapItem) {
        id = UUID()
        name = mapItem.name ?? ""
        title = mapItem.placemark.title ?? ""
        location = mapItem.placemark.location
        countryCode = mapItem.placemark.countryCode
        print("countryCode: \(countryCode)")
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
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .id)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        location = CLLocation(latitude: latitude, longitude: longitude)
        countryCode = try container.decode(String.self, forKey: .countryCode)
    }
}

extension Location: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(title, forKey: .title)
        try container.encode(location?.coordinate.latitude, forKey: .latitude)
        try container.encode(location?.coordinate.longitude, forKey: .longitude)
        try container.encode(countryCode, forKey: .countryCode)
    }
}
