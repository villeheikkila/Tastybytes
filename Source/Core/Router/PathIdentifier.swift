import Models
import SwiftUI

struct DeepLinkHandler {
    let url: URL
    let deeplinkSchemes: [String]

    init(url: URL, deeplinkSchemes: [String]) {
        self.url = url
        self.deeplinkSchemes = deeplinkSchemes
    }

    var isUniversalLink: Bool {
        url.scheme == "https"
    }

    var isDeepLink: Bool {
        guard let scheme = url.scheme else { return false }
        return deeplinkSchemes.contains(scheme)
    }

    var pathIdentifier: PathIdentifier? {
        guard isUniversalLink || isDeepLink, url.pathComponents.count == 3 else { return nil }

        switch url.pathComponents[1] {
        case "checkins": return .checkins
        case "products": return .products
        case "profiles": return .profiles
        case "companies": return .companies
        case "brands": return .brands
        case "locations": return .locations
        default: return nil
        }
    }

    var detailPage: NavigatablePath? {
        guard let pathIdentifier else { return nil }
        let path = url.pathComponents[2]

        switch pathIdentifier {
        case .products:
            guard let id = Product.Id(path) else { return nil }
            return .product(id: id)
        case .checkins:
            guard let id = CheckIn.Id(path) else { return nil }
            return .checkIn(id: id)
        case .profiles:
            guard let uuid = Profile.Id(uuidString: path) else { return nil }
            return .profile(id: uuid)
        case .brands:
            guard let id = Brand.Id(path) else { return nil }
            return .brand(id: id)
        case .companies:
            guard let id = Company.Id(path) else { return nil }
            return .company(id: id)
        case .locations:
            guard let id = Location.Id(uuidString: path) else { return nil }
            return .location(id: id)
        }
    }
}
