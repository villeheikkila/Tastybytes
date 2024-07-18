import Models
import OSLog
import Repositories
import StoreKit
import SwiftUI

@MainActor
@Observable
final class SubscriptionEnvironmentModel {
    private let logger = Logger(category: "SubscriptionEnvironmentModel")
    let productSubscription = ProductSubscription()
    private var activeTransactions: Set<StoreKit.Transaction> = []

    let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    var subscriptionStatus: SubscriptionStatus = .notSubscribed

    func onTaskStatusChange(taskStatus: EntitlementTaskState<[StoreKit.Product.SubscriptionInfo.Status]>, productSubscriptions: [SubscriptionProduct]) async {
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
            logger.error("Purchase failed: \(error)")
        }
    }

    func onPurchaseResult(product: StoreKit.Product, result: StoreKit.Product.PurchaseResult) async {
        switch result {
        case let .success(transaction):
            logger.info("Purchases for \(product.displayName) successful at \(transaction.signedDate)")
            if let transaction = try? transaction.payloadValue {
                activeTransactions.insert(transaction)
                await insertTransactionIntoDatabase(transaction: transaction)
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

    func initializeActiveTransactions() async {
        var activeTransactions: Set<StoreKit.Transaction> = []

        for await entitlement in StoreKit.Transaction.currentEntitlements {
            if let transaction = try? entitlement.payloadValue {
                activeTransactions.insert(transaction)
                // keep database in sync by reuploading all transactions
                // this might be excessive but in practise user should have only one valid subscription at the time
                await insertTransactionIntoDatabase(transaction: transaction)
            }
        }
        self.activeTransactions = activeTransactions
    }

    func insertTransactionIntoDatabase(transaction: StoreKit.Transaction) async {
        do {
            try await repository.subscription.syncSubscriptionTransaction(transactionInfo: .init(transaction: transaction))
            logger.info("Synced transaction to the server")
        } catch {
            logger.error("Failed to sync transaction. Error: \(error) (\(#file):\(#line))")
        }
    }
}
