import EnvironmentModels
import Models
import StoreKit
import SwiftUI

@MainActor
struct SubscriptionStoreContentView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel

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

    var image: some View {
        Image(.projectLogo)
            .resizable()
            .accessibilityHidden(true)
            .aspectRatio(contentMode: .fit)
            .frame(width: 100)
    }

    var title: some View {
        Text("\(appEnvironmentModel.infoPlist.appName) \(subscriptionGroupName)")
            .font(.largeTitle.bold())
    }

    var desctiption: some View {
        Text("Unlock additional features")
            .fixedSize(horizontal: false, vertical: true)
            .font(.title3.weight(.medium))
            .padding([.bottom, .horizontal])
            .foregroundStyle(.gray)
            .multilineTextAlignment(.center)
    }
}
