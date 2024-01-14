import Models
import OSLog
import Repositories
import StoreKit
import SwiftUI

@MainActor
@Observable class SubscriptionEnvironmentModel {
    private let logger = Logger(category: "SubscriptionEnvironmentModel")
    var productSubscription = ProductSubscription()

    let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    var subscriptionStatus: SubscriptionStatus = .notSubscribed

    func onTaskStatusChange(taskStatus: EntitlementTaskState<[StoreKit.Product.SubscriptionInfo.Status]>, productSubscriptions: [Subscription]) async {
        let status = await productSubscription.getStatusFromTaskStatus(taskStatuses: taskStatus, productSubscriptions: productSubscriptions)
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

    func onInAppPurchaseCompletion(product: StoreKit.Product, result: Result<StoreKit.Product.PurchaseResult, Error>) async {
        switch result {
        case let .success(result):
            await onPurchaseResult(product: product, result: result)
        case let .failure(error):
            logger.error("Purchase failed, \(error)")
        }
    }

    func onPurchaseResult(product: StoreKit.Product, result: StoreKit.Product.PurchaseResult) async {
        switch result {
        case let .success(transaction):
            logger.info("Purchases for \(product.displayName) successful at \(transaction.signedData)")
        case .pending:
            logger.info("Purchases for \(product.displayName) pending user action")
        case .userCancelled:
            logger.info("Purchases for \(product.displayName) was cancelled by the user")
        @unknown default:
            logger.error("Encountered unknown purchase result")
        }
    }
}
