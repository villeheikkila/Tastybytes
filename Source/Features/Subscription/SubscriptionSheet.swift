
import StoreKit
import SwiftUI

struct SubscriptionSheet: View {
    @Environment(ProfileModel.self) private var profileModel
    @Environment(AppModel.self) private var appModel

    var body: some View {
        if let subscriptionGroup = appModel.subscriptionGroup {
            SubscriptionStoreView(groupID: subscriptionGroup.groupId) {
                SubscriptionStoreContentView(subscriptionGroupName: subscriptionGroup.name)
            }
            .backgroundStyle(.clear)
            .storeButton(.visible, for: .restorePurchases, .redeemCode)
            .subscriptionStoreButtonLabel(.multiline)
            .subscriptionStoreControlStyle(.prominentPicker)
            .subscriptionStorePolicyDestination(for: .privacyPolicy) {
                PrivacyPolicyView()
            }
            .subscriptionStorePolicyDestination(for: .termsOfService) {
                TermsOfServiceView()
            }
            .subscriptionStorePickerItemBackground(.thinMaterial)
            .storeButton(.visible, for: .restorePurchases)
            .onInAppPurchaseCompletion(perform: profileModel.onInAppPurchaseCompletion)
        }
    }
}

#Preview {
    SubscriptionSheet()
}
