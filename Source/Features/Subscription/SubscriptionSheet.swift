import EnvironmentModels
import StoreKit
import SwiftUI

struct SubscriptionSheet: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel

    var body: some View {
        SubscriptionStoreView(groupID: appEnvironmentModel.subscriptionGroup.groupId) {
            SubscriptionStoreContentView(subscriptionGroupName: appEnvironmentModel.subscriptionGroup.name)
        }
        .backgroundStyle(.clear)
        .subscriptionStoreButtonLabel(.multiline)
        .subscriptionStorePickerItemBackground(.thinMaterial)
        .storeButton(.visible, for: .restorePurchases)
    }
}

#Preview {
    SubscriptionSheet()
}
