import OSLog
import SwiftUI

enum NavigatablePath {
    case product(id: Int)
    case checkIn(id: Int)
    case company(id: Int)
    case profile(id: UUID)
    case location(id: UUID)
    case brand(id: Int)

    var urlString: String {
        switch self {
        case let .profile(id):
            return "\(Config.baseUrl)/\(PathIdentifier.profiles)/\(id.uuidString.lowercased())"
        case let .checkIn(id):
            return "\(Config.baseUrl)/\(PathIdentifier.checkins)/\(id)"
        case let .product(id):
            return "\(Config.baseUrl)/\(PathIdentifier.products)/\(id)"
        case let .company(id):
            return "\(Config.baseUrl)/\(PathIdentifier.companies)/\(id)"
        case let .brand(id):
            return "\(Config.baseUrl)/\(PathIdentifier.brands)/\(id)"
        case let .location(id):
            return "\(Config.baseUrl)/\(PathIdentifier.locations)/\(id.uuidString.lowercased())"
        }
    }

    var url: URL {
        // swiftlint:disable force_unwrapping
        URL(string: urlString)!
        // swiftlint:enable force_unwrapping
    }
}
