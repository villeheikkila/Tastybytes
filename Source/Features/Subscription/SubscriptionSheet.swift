import StoreKit
import SwiftUI

struct SubscriptionSheet: View {
    @Environment(SubscriptionEnvironmentModel.self) private var subscriptionEnvironmentModel

    var body: some View {
        if let subscriptionGroup = subscriptionEnvironmentModel.subscriptionGroup {
            SubscriptionStoreView(groupID: subscriptionGroup.groupId) {
                SubscriptionStoreContentView(subscriptionGroupName: subscriptionGroup.name)
            }
            .backgroundStyle(.clear)
            .subscriptionStoreButtonLabel(.multiline)
            .subscriptionStorePickerItemBackground(.thinMaterial)
            .storeButton(.visible, for: .restorePurchases)
        }
    }
}

#Preview {
    SubscriptionSheet()
}
