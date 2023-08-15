import OSLog
import StoreKit
import SwiftUI

actor ProductSubscription {
    private let logger = Logger(category: "ProductSubscription")
    private(set) static var shared: ProductSubscription!

    private init() {}

    static func createSharedInstance() {
        shared = ProductSubscription()
    }

    func status(for statuses: [StoreKit.Product.SubscriptionInfo.Status],
                ids: SubscriptionIdentifier) -> SubscriptionStatus
    {
        let effectiveStatus = statuses.max { lhs, rhs in
            let lhsStatus = SubscriptionStatus(
                productID: lhs.transaction.unsafePayloadValue.productID,
                ids: ids
            ) ?? .notSubscribed
            let rhsStatus = SubscriptionStatus(
                productID: rhs.transaction.unsafePayloadValue.productID,
                ids: ids
            ) ?? .notSubscribed
            return lhsStatus < rhsStatus
        }
        guard let effectiveStatus else {
            return .notSubscribed
        }

        let transaction: StoreKit.Transaction

        switch effectiveStatus.transaction {
        case let .verified(t):
            transaction = t
        case let .unverified(_, error):
            logger.error("Error occured while checking status: \(error)")
            return .notSubscribed
        }

        if case .autoRenewable = transaction.productType {
            if !(transaction.revocationDate == nil && transaction.revocationReason == nil) {
                return .notSubscribed
            }
            if let subscriptionExpirationDate = transaction.expirationDate {
                if subscriptionExpirationDate.timeIntervalSince1970 < Date().timeIntervalSince1970 {
                    return .notSubscribed
                }
            }
        }

        return SubscriptionStatus(productID: transaction.productID, ids: ids) ?? .notSubscribed
    }
}

extension ProductSubscription {
    func process(transaction _: VerificationResult<StoreKit.Transaction>) async {}

    func checkForUnfinishedTransactions() async {
        for await transaction in Transaction.unfinished {
            Task.detached(priority: .background) {
                await self.process(transaction: transaction)
            }
        }
    }

    func observeTransactionUpdates() async {
        for await update in Transaction.updates {
            await process(transaction: update)
        }
    }
}
