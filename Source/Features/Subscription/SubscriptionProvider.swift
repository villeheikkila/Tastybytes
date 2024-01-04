import OSLog
import StoreKit
import SwiftUI

struct SubscriptionProvider<Content: View>: View {
    private let logger = Logger(category: "SubscriptionProvider")
    @State private var status: EntitlementTaskState<SubscriptionStatus> = .loading
    @State private var subscriptionEnvironmentModel = SubscriptionEnvironmentModel()
    @Environment(\.productSubscriptionIds) private var productSubscriptionIds
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .environment(subscriptionEnvironmentModel)
            .onAppear(perform: {
                ProductSubscription.createSharedInstance()
            })
            .subscriptionStatusTask(for: productSubscriptionIds.group) { taskStatus in
                status = await taskStatus.map { statuses in
                    await ProductSubscription.shared.status(
                        for: statuses,
                        ids: productSubscriptionIds
                    )
                }
                switch status {
                case let .failure(error):
                    subscriptionEnvironmentModel.subscriptionStatus = .notSubscribed
                    logger.error("Failed to check subscription status: \(error)")
                case let .success(status):
                    subscriptionEnvironmentModel.subscriptionStatus = status
                case .loading: break
                @unknown default: break
                }
            }
            .task {
                await ProductSubscription.shared.observeTransactionUpdates()
                await ProductSubscription.shared.checkForUnfinishedTransactions()
            }
    }
}
