import StoreKit
import SwiftUI

struct SubscriptionSheet: View {
    @Environment(\.productSubscriptionIds.group) private var groupId

    var body: some View {
        SubscriptionStoreView(groupID: groupId) {
            SubscriptionStoreContentView()
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
