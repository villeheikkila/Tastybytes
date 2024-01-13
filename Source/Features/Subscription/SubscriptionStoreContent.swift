import Models
import StoreKit
import SwiftUI
import EnvironmentModels

@MainActor
struct SubscriptionStoreContentView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel

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
            .aspectRatio(contentMode: .fit)
            .frame(width: 100)
    }

    var title: some View {
        Text("\(appEnvironmentModel.infoPlist.appName) Pro")
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
