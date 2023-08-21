import Models
import SwiftUI

enum PathIdentifier: Hashable {
    case checkins, products, profiles, companies, locations, brands
}

extension URL {
    var isUniversalLink: Bool {
        scheme == "https"
    }

    var isDeepLink: Bool {
        scheme == Config.deeplinkSchema
    }

    var pathIdentifier: PathIdentifier? {
        guard isUniversalLink || isDeepLink, pathComponents.count == 3 else { return nil }

        return switch pathComponents[1] {
        case "checkins": .checkins
        case "products": .products
        case "profiles": .profiles
        case "companies": .companies
        case "brands": .brands
        case "locations": .locations
        default: nil
        }
    }

    var detailPage: NavigatablePath? {
        guard let pathIdentifier
        else {
            return nil
        }

        let path = pathComponents[2]

        switch pathIdentifier {
        case .products:
            guard let id = Int(path) else {
                return nil
            }
            return .product(id: id)
        case .checkins:
            guard let id = Int(path) else {
                return nil
            }
            return .checkIn(id: id)
        case .profiles:
            guard let uuid = UUID(uuidString: path) else {
                return nil
            }
            return .profile(id: uuid)
        case .brands:
            guard let id = Int(path) else {
                return nil
            }
            return .brand(id: id)
        case .companies:
            guard let id = Int(path) else {
                return nil
            }
            return .company(id: id)
        case .locations:
            guard let id = UUID(uuidString: path) else { return nil }
            return .location(id: id)
        }
    }
}
