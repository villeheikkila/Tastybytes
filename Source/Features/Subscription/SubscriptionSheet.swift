import EnvironmentModels
import StoreKit
import SwiftUI

@MainActor
struct SubscriptionSheet: View {
    @Environment(SubscriptionEnvironmentModel.self) private var subscriptionEnvironmentModel
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel

    var body: some View {
        if let subscriptionGroup = appEnvironmentModel.subscriptionGroup {
            SubscriptionStoreView(groupID: subscriptionGroup.groupId) {
                SubscriptionStoreContentView(subscriptionGroupName: subscriptionGroup.name)
            }
            .backgroundStyle(.clear)
            .storeButton(.visible, for: .restorePurchases, .redeemCode)
            .subscriptionStorePolicyDestination(for: .privacyPolicy) {
                EmptyView()
            }
            .subscriptionStorePolicyDestination(for: .termsOfService) {
                EmptyView()
            }
            .subscriptionStoreButtonLabel(.multiline)
            .subscriptionStoreControlStyle(.prominentPicker)
            .subscriptionStorePickerItemBackground(.thinMaterial)
            .storeButton(.visible, for: .restorePurchases)
            .onInAppPurchaseCompletion(perform: subscriptionEnvironmentModel.onInAppPurchaseCompletion)
        }
    }
}

#Preview {
    SubscriptionSheet()
}
