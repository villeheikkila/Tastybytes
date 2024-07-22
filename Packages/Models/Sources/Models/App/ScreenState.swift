import SwiftUI

public enum ScreenState: Equatable {
    case loading
    case populated
    case error([Error])

    public static func == (lhs: ScreenState, rhs: ScreenState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.populated, .populated):
            true
        case let (.error(lhsErrors), .error(rhsErrors)):
            lhsErrors.count == rhsErrors.count && lhsErrors.elementsEqual(rhsErrors, by: { $0.localizedDescription == $1.localizedDescription })
        default:
            false
        }
    }

    public var isPopulated: Bool {
        self == .populated
    }
}
