
import OSLog
import StoreKit
import SwiftUI

struct SubscriptionProvider<Content: View>: View {
    @Environment(AppModel.self) private var appModel
    @Environment(SubscriptionModel.self) private var subscriptionModel
    @ViewBuilder let content: () -> Content
    @State private var isPro = false

    var body: some View {
        Group {
            if let subscriptionGroup = appModel.subscriptionGroup {
                content()
                    .subscriptionStatusTask(for: subscriptionGroup.groupId) { taskStatus in
                        await subscriptionModel.onTaskStatusChange(taskStatus: taskStatus, productSubscriptions: subscriptionGroup.subscriptions)
                    }
            }
        }
    }
}
