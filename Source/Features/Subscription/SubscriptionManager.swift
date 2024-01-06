import OSLog
import StoreKit
import SwiftUI

@Observable class SubscriptionEnvironmentModel {
    private let logger = Logger(category: "SubscriptionEnvironmentModel")
    var productSubscription = ProductSubscription()

    var subscriptionStatus: SubscriptionStatus = .notSubscribed

    func onTaskStatusChange(taskStatus: EntitlementTaskState<[Product.SubscriptionInfo.Status]>, productSubscriptionIds: SubscriptionIdentifier) async {
        let status = await productSubscription.getStatusFromTaskStatus(taskStatuses: taskStatus, productSubscriptionIds: productSubscriptionIds)
        switch status {
        case let .failure(error):
            subscriptionStatus = .notSubscribed
            logger.error("Failed to check subscription status: \(error)")
        case let .success(status):
            subscriptionStatus = status
        case .loading: break
        @unknown default: break
        }
    }
}
