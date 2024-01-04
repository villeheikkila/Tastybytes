import StoreKit
import SwiftUI

enum SubscriptionStatus: Comparable, Hashable, Sendable {
    case notSubscribed
    case monthly
    case yearly

    init?(productID: StoreKit.Product.ID, ids: SubscriptionIdentifier) {
        switch productID {
        case ids.monthly: self = .monthly
        case ids.yearly: self = .yearly
        default: return nil
        }
    }

    var description: String {
        switch self {
        case .notSubscribed:
            "Not Subscribed"
        case .monthly:
            "Monthly"
        case .yearly:
            "Yearly"
        }
    }
}
