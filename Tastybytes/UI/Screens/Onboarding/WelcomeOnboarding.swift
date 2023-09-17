import Models
import SwiftUI

struct WelcomeOnboarding: View {
    @Binding var currentTab: OnboardingScreen.Tab
    let nextTab: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                appIcon
                Spacer()
            }
            .padding()
            VStack(alignment: .leading) {
                ForEach(features, id: \.self) { feature in
                    feature.view
                }
            }
            .padding()
            Spacer()
        }
        .padding(.top, 50)
        .modifier(OnboardingContinueButtonModifier(title: "Continue", onClick: {
            nextTab()
        }))
    }

    let features: [FeatureItem] = [FeatureItem(
        title: "Activity Feed",
        description: "Find out what your friends have been tasting",
        systemName: "list.start",
        color: .blue
    ),
    FeatureItem(
        title: "Discover",
        description: "See notes and ratings from other users",
        systemName: "sparkle.magnifyingglass",
        color: .yellow
    ),
    FeatureItem(
        title: "Statistics",
        description: "See the overview of your tasting habits and locations",
        systemName: "chart.xyaxis.line",
        color: .orange
    ),
    FeatureItem(
        title: "Wishlist",
        description: "Explore, save, indulge.",
        systemName: "heart.fill",
        color: .red
    )]

    var appIcon: some View {
        HStack(spacing: 18) {
            Image(AppIcon.ramune.logo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60, alignment: .center)
                .accessibility(hidden: true)

            VStack(alignment: .leading, spacing: 6) {
                Text(Config.appName)
                    .font(.title)
                    .fontWeight(.bold)

                Text("The definite app for storing and sharing tasting notes")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct FeatureItem: Hashable {
    let title: String
    let description: String
    let systemName: String
    let color: Color

    @ViewBuilder var view: some View {
        HStack(alignment: .center) {
            HStack {
                Image(systemName: systemName)
                    .font(.system(size: 50))
                    .frame(width: 50)
                    .foregroundColor(color)
                    .padding()
                    .accessibility(hidden: true)
                    .foregroundColor(color)

                VStack(alignment: .leading) {
                    Text(title)
                        .bold()
                        .foregroundColor(.primary)

                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
