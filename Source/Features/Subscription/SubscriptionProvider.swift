import OSLog
import StoreKit
import SwiftUI

struct SubscriptionProvider<Content: View>: View {
    private let logger = Logger(category: "SubscriptionProvider")
    @State private var status: EntitlementTaskState<SubscriptionStatus> = .loading
    @State private var subscriptionStatusEnvironmentModel = SubscriptionStatusEnvironmentModel()
    @Environment(\.productSubscriptionIds) private var productSubscriptionIds
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .environment(subscriptionStatusEnvironmentModel)
            .subscriptionStatusTask(for: productSubscriptionIds.group) { taskStatus in
                status = await taskStatus.map { statuses in
                    await subscriptionStatusEnvironmentModel.productSubscription.status(
                        for: statuses,
                        ids: productSubscriptionIds
                    )
                }
                switch status {
                case let .failure(error):
                    subscriptionStatusEnvironmentModel.subscriptionStatus = .notSubscribed
                    logger.error("Failed to check subscription status: \(error)")
                case let .success(status):
                    subscriptionStatusEnvironmentModel.subscriptionStatus = status
                case .loading: break
                @unknown default: break
                }
            }
            .task {
                await subscriptionStatusEnvironmentModel.productSubscription.observeTransactionUpdates()
                await subscriptionStatusEnvironmentModel.productSubscription.checkForUnfinishedTransactions()
            }
    }
}
