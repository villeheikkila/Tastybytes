import Models
import OSLog
import Repositories
import StoreKit
import SwiftUI

@MainActor
@Observable class SubscriptionEnvironmentModel {
    private let logger = Logger(category: "SubscriptionEnvironmentModel")
    var productSubscription = ProductSubscription()
    public var subscriptionGroup: SubscriptionGroup.Joined?

    let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    var subscriptionStatus: SubscriptionStatus = .notSubscribed

    func onTaskStatusChange(taskStatus: EntitlementTaskState<[StoreKit.Product.SubscriptionInfo.Status]>) async {
        let status = await productSubscription.getStatusFromTaskStatus(taskStatuses: taskStatus, productSubscriptions: subscriptionGroup?.subscriptions ?? [])
        switch status {
        case let .success(status):
            subscriptionStatus = status
            logger.info("Subscription status: \(status.description)")
        case let .failure(error):
            subscriptionStatus = .notSubscribed
            logger.error("Failed to check subscription status: \(error)")
        case .loading: break
        @unknown default: break
        }
    }

    public func initializeProductIds() async {
        switch await repository.subscription.getActiveGroup() {
        case let .success(subscriptionGroup):
            logger.info("Initialized subscription group: \(subscriptionGroup.name)")
            self.subscriptionGroup = subscriptionGroup
        case let .failure(error):
            logger.error("Failed to load product ids. Error: \(error) (\(#file):\(#line))")
        }
    }
}
