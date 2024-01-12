import OSLog
import SwiftUI

public enum NavigatablePath: Sendable {
    case product(id: Int)
    case productWithBarcode(id: Int, barcode: Barcode)
    case checkIn(id: Int)
    case company(id: Int)
    case profile(id: UUID)
    case location(id: UUID)
    case brand(id: Int)

    private var path: String {
        switch self {
        case let .profile(id):
            "\(PathIdentifier.profiles)/\(id.uuidString.lowercased())"
        case let .checkIn(id):
            "\(PathIdentifier.checkins)/\(id)"
        case let .product(id), let .productWithBarcode(id, _):
            "\(PathIdentifier.products)/\(id)"
        case let .company(id):
            "\(PathIdentifier.companies)/\(id)"
        case let .brand(id):
            "\(PathIdentifier.brands)/\(id)"
        case let .location(id):
            "\(PathIdentifier.locations)/\(id.uuidString.lowercased())"
        }
    }

    public func getUrl(baseUrl: URL) -> URL {
        baseUrl.appendingPathComponent(path)
    }
}

public enum PathIdentifier: Hashable {
    case checkins, products, profiles, companies, locations, brands
}
