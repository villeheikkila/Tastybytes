import SwiftUI

public enum ScreenState: Equatable {
    case loading
    case populated
    case error(Error)

    public static func == (lhs: ScreenState, rhs: ScreenState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.populated, .populated):
            true
        case let (.error(lhsErrors), .error(rhsErrors)):
            lhsErrors.localizedDescription == rhsErrors.localizedDescription
        default:
            false
        }
    }

    public var isPopulated: Bool {
        if case .populated = self {
            return true
        }
        return false
    }
}
