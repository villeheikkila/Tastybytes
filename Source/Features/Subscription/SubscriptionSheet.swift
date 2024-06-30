import EnvironmentModels
import StoreKit
import SwiftUI

struct SubscriptionSheet: View {
    @Environment(SubscriptionEnvironmentModel.self) private var subscriptionEnvironmentModel
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel

    var body: some View {
        if let subscriptionGroup = appEnvironmentModel.subscriptionGroup {
            SubscriptionStoreView(groupID: subscriptionGroup.groupId) {
                SubscriptionStoreContentView(subscriptionGroupName: subscriptionGroup.name)
            }
            .backgroundStyle(.clear)
            #if !os(watchOS)
                .storeButton(.visible, for: .restorePurchases, .redeemCode)
                .subscriptionStoreButtonLabel(.multiline)
                .subscriptionStoreControlStyle(.prominentPicker)
            #endif
                .subscriptionStorePolicyDestination(for: .privacyPolicy) {
                    EmptyView()
                }
                .subscriptionStorePolicyDestination(for: .termsOfService) {
                    EmptyView()
                }
                .subscriptionStorePickerItemBackground(.thinMaterial)
                .storeButton(.visible, for: .restorePurchases)
                .onInAppPurchaseCompletion(perform: subscriptionEnvironmentModel.onInAppPurchaseCompletion)
        }
    }
}

#Preview {
    SubscriptionSheet()
}
