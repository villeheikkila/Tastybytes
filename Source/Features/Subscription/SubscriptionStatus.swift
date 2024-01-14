import Models
import StoreKit
import SwiftUI

enum SubscriptionStatus: Comparable, Hashable, Sendable {
    case notSubscribed
    case subscribed(SubscriptionProduct)

    init?(productID: StoreKit.Product.ID, productSubscriptions: [SubscriptionProduct]) {
        if let matchedSubscription = productSubscriptions.first(where: { $0.id == productID }) {
            self = .subscribed(matchedSubscription)
        } else {
            self = .notSubscribed
        }
    }

    static func < (lhs: SubscriptionStatus, rhs: SubscriptionStatus) -> Bool {
        switch (lhs, rhs) {
        case (.notSubscribed, .subscribed):
            true
        case (.subscribed, .notSubscribed):
            false
        case (.notSubscribed, .notSubscribed):
            false
        case let (.subscribed(sub1), .subscribed(sub2)):
            sub1.priority < sub2.priority
        }
    }

    var description: String {
        switch self {
        case .notSubscribed:
            "Not subscribed"
        case let .subscribed(subscription):
            "Subscribed to \(subscription)"
        }
    }
}
