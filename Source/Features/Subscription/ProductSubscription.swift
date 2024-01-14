import Models
import OSLog
import StoreKit
import SwiftUI

actor ProductSubscription {
    private let logger = Logger(category: "ProductSubscription")

    public init() {}

    public func getStatusFromTaskStatus(taskStatuses: EntitlementTaskState<[StoreKit.Product.SubscriptionInfo.Status]>, productSubscriptions: [SubscriptionProduct]) async -> EntitlementTaskState<SubscriptionStatus> {
        taskStatuses.map { statuses in
            status(
                for: statuses,
                productSubscriptions: productSubscriptions
            )
        }
    }

    private func status(for statuses: [StoreKit.Product.SubscriptionInfo.Status],
                        productSubscriptions: [SubscriptionProduct]) -> SubscriptionStatus
    {
        let effectiveStatus = statuses.max { lhs, rhs in
            let lhsStatus = SubscriptionStatus(
                productID: lhs.transaction.unsafePayloadValue.productID,
                productSubscriptions: productSubscriptions
            ) ?? .notSubscribed
            let rhsStatus = SubscriptionStatus(
                productID: rhs.transaction.unsafePayloadValue.productID,
                productSubscriptions: productSubscriptions
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

        if case .autoRenewable = transaction.productType,
           transaction.revocationDate != nil || transaction.revocationReason != nil,
           let expirationDate = transaction.expirationDate,
           expirationDate.timeIntervalSince1970 < Date().timeIntervalSince1970
        {
            return .notSubscribed
        }

        return .init(productID: transaction.productID, productSubscriptions: productSubscriptions) ?? .notSubscribed
    }

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
