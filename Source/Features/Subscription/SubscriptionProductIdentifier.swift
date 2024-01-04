import SwiftUI

struct SubscriptionIdentifier: Sendable {
    var group: String
    var monthly: String
    var yearly: String
}

extension EnvironmentValues {
    private enum SubscriptionIDKey: EnvironmentKey, Sendable {
        static var defaultValue = SubscriptionIdentifier(
            group: "21373294",
            monthly: "com.tastybytes.pro.monthly",
            yearly: "com.tastybytes.pro.yearly"
        )
    }

    var productSubscriptionIds: SubscriptionIdentifier {
        get { self[SubscriptionIDKey.self] }
        set { self[SubscriptionIDKey.self] = newValue }
    }
}
