import SwiftUI

@Observable class SubscriptionStatusEnvironmentModel {
    var subscriptionStatus: SubscriptionStatus = .notSubscribed

    var productSubscription = ProductSubscription()
}
