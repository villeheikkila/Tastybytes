import EnvironmentModels
import StoreKit
import SwiftUI

struct SubscriptionSheet: View {
    @Environment(SubscriptionEnvironmentModel.self) private var subscriptionEnvironmentModel
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel

    var body: some View {
        SubscriptionStoreView(groupID: appEnvironmentModel.subscriptionGroup.groupId) {
            SubscriptionStoreContentView(subscriptionGroupName: appEnvironmentModel.subscriptionGroup.name)
        }
        .backgroundStyle(.clear)
        .storeButton(.visible, for: .restorePurchases, .redeemCode)
        .subscriptionStorePolicyDestination(for: .privacyPolicy) {
            Text("Privacy policy here")
        }
        .subscriptionStorePolicyDestination(for: .termsOfService) {
            Text("Terms of service here")
        }
        .subscriptionStoreButtonLabel(.multiline)
        .subscriptionStoreControlStyle(.prominentPicker)
        .subscriptionStorePickerItemBackground(.thinMaterial)
        .storeButton(.visible, for: .restorePurchases)
        .onInAppPurchaseCompletion(perform: subscriptionEnvironmentModel.onInAppPurchaseCompletion)
    }
}

#Preview {
    SubscriptionSheet()
}
