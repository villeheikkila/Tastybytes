import OSLog
import SwiftUI

enum NavigatablePath {
    case product(id: Int)
    case productWithBarcode(id: Int, barcode: Barcode)
    case checkIn(id: Int)
    case company(id: Int)
    case profile(id: UUID)
    case location(id: UUID)
    case brand(id: Int)

    var urlString: String {
        switch self {
        case let .profile(id):
            "\(Config.baseUrl)/\(PathIdentifier.profiles)/\(id.uuidString.lowercased())"
        case let .checkIn(id):
            "\(Config.baseUrl)/\(PathIdentifier.checkins)/\(id)"
        case let .product(id), let .productWithBarcode(id, _):
            "\(Config.baseUrl)/\(PathIdentifier.products)/\(id)"
        case let .company(id):
            "\(Config.baseUrl)/\(PathIdentifier.companies)/\(id)"
        case let .brand(id):
            "\(Config.baseUrl)/\(PathIdentifier.brands)/\(id)"
        case let .location(id):
            "\(Config.baseUrl)/\(PathIdentifier.locations)/\(id.uuidString.lowercased())"
        }
    }

    var url: URL {
        // swiftlint:disable force_unwrapping
        URL(string: urlString)!
        // swiftlint:enable force_unwrapping
    }
}
