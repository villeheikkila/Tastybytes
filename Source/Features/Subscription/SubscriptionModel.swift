import Logging
import Models
import Repositories
import StoreKit
import SwiftUI

@MainActor
@Observable
final class SubscriptionModel {
    private let logger = Logger(label: "SubscriptionModel")
    let productSubscription = ProductSubscription()
    private var activeTransactions: Set<StoreKit.Transaction> = []

    private let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    var subscriptionStatus: SubscriptionStatus = .notSubscribed
    var isProMember = false

    func onTaskStatusChange(taskStatus: EntitlementTaskState<[StoreKit.Product.SubscriptionInfo.Status]>, productSubscriptions _: [SubscriptionProduct]) async {
        if let value = taskStatus.value {
            let isPro = !value
                .filter { $0.state != .revoked && $0.state != .expired }
                .isEmpty
            isProMember = isPro
            logger.info("User is a \(isPro ? "pro" : "regular") member")
        } else {
            logger.info("User is a regular member")
            isProMember = false
        }
    }

    func onInAppPurchaseCompletion(product: StoreKit.Product, result: Result<StoreKit.Product.PurchaseResult, Error>) async {
        switch result {
        case let .success(result):
            await onPurchaseResult(product: product, result: result)
        case let .failure(error):
            logger.error("Purchase failed: \(error)")
        }
    }

    func onPurchaseResult(product: StoreKit.Product, result: StoreKit.Product.PurchaseResult) async {
        switch result {
        case let .success(transaction):
            logger.info("Purchases for \(product.displayName) successful at \(transaction.signedDate)")
            if let transaction = try? transaction.payloadValue {
                activeTransactions.insert(transaction)
                await transaction.finish()
            }
        case .pending:
            logger.info("Purchases for \(product.displayName) pending user action")
        case .userCancelled:
            logger.info("Purchases for \(product.displayName) was cancelled by the user")
        @unknown default:
            logger.error("Encountered unknown purchase result")
        }
    }

    var isRegularMember: Bool {
        !isProMember
    }
}
