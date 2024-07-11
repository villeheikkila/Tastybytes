import EnvironmentModels
import OSLog
import StoreKit
import SwiftUI

struct SubscriptionProvider<Content: View>: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(SubscriptionEnvironmentModel.self) private var subscriptionEnvironmentModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        Group {
            if let subscriptionGroup = appEnvironmentModel.subscriptionGroup {
                content()
                    .subscriptionStatusTask(for: subscriptionGroup.groupId) { taskStatus in
                        await subscriptionEnvironmentModel.onTaskStatusChange(taskStatus: taskStatus, productSubscriptions: subscriptionGroup.subscriptions)
                    }
                    .task {
                        await subscriptionEnvironmentModel.initializeActiveTransactions()
                    }
//                    .task {
//                        await subscriptionEnvironmentModel.productSubscription.observeTransactionUpdates()
//                    }
//                    .task {
//                        await subscriptionEnvironmentModel.productSubscription.checkForUnfinishedTransactions()
//                    }
            }
        }
    }
}
