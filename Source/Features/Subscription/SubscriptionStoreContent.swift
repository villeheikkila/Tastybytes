
import Models
import StoreKit
import SwiftUI

struct SubscriptionStoreContentView: View {
    @Environment(AppModel.self) private var appModel

    let subscriptionGroupName: String

    var body: some View {
        VStack {
            image
            VStack(spacing: 3) {
                title
                desctiption
            }
        }
        .padding(.vertical)
        .padding(.top, 40)
    }

    private var image: some View {
        Image(.projectLogo)
            .resizable()
            .accessibilityHidden(true)
            .aspectRatio(contentMode: .fit)
            .frame(width: 100)
    }

    private var title: some View {
        Text("\(appModel.infoPlist.appName) \(subscriptionGroupName)")
            .font(.largeTitle.bold())
    }

    private var desctiption: some View {
        Text("subscription.callToAction.description")
            .fixedSize(horizontal: false, vertical: true)
            .font(.title3.weight(.medium))
            .padding([.bottom, .horizontal])
            .foregroundStyle(.gray)
            .multilineTextAlignment(.center)
    }
}
