import OSLog
import StoreKit
import SwiftUI

@MainActor
struct SubscriptionProvider<Content: View>: View {
    private let logger = Logger(category: "SubscriptionProvider")
    @State private var status: EntitlementTaskState<SubscriptionStatus> = .loading
    @State private var subscriptionStatusEnvironmentModel = SubscriptionStatusEnvironmentModel()
    @State private var subscriptionEnvironmentModel = ProductSubscriptionEnvironmentModel()
    @Environment(\.productSubscriptionIds) private var productSubscriptionIds
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .environment(subscriptionStatusEnvironmentModel)
            .subscriptionStatusTask(for: productSubscriptionIds.group) { taskStatus in
                status = await taskStatus.map { statuses in
                    await subscriptionEnvironmentModel.status(
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
                await subscriptionEnvironmentModel.observeTransactionUpdates()
                await subscriptionEnvironmentModel.checkForUnfinishedTransactions()
            }
    }
}
