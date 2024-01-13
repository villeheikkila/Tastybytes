import SwiftUI

struct SubscriptionIdentifier: Sendable {
    var group: String
    var monthly: String
    var yearly: String
}

extension EnvironmentValues {
    private enum SubscriptionIDKey: EnvironmentKey, Sendable {
        static var defaultValue = SubscriptionIdentifier(
            group: "21434122",
            monthly: "monthly",
            yearly: "yearly"
        )
    }

    var productSubscriptionIds: SubscriptionIdentifier {
        get { self[SubscriptionIDKey.self] }
        set { self[SubscriptionIDKey.self] = newValue }
    }
}
