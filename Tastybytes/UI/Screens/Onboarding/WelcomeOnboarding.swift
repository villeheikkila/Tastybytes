import SFSafeSymbols
import SwiftUI

struct WelcomeOnboarding: View {
  @Binding var currentTab: OnboardingScreen.Tab
  let nextTab: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 60) {
      HStack {
        Spacer()
        appIcon
        Spacer()
      }
      VStack(alignment: .leading, spacing: 30) {
        ForEach(features, id: \.self) { feature in
          feature.view
        }
      }
      .padding(.horizontal)
      Spacer()
    }
    .padding(.top, 40)
    .modifier(OnboardingContinueButtonModifier(title: "Continue", onClick: {
      nextTab()
    }))
  }

  let features: [FeatureItem] = [FeatureItem(
    title: "Activity Feed",
    description: "Find out what your friends have been tasting",
    systemSymbol: .listStar,
    color: .blue
  ),
  FeatureItem(
    title: "Discover",
    description: "See notes and ratings from other users",
    systemSymbol: .sparkleMagnifyingglass,
    color: .yellow
  ),
  FeatureItem(
    title: "Statistics",
    description: "See overview on your tasting habits",
    systemSymbol: .chartXyaxisLine,
    color: .orange
  )]

  var appIcon: some View {
    HStack(spacing: 12) {
      Image(AppIcon.ramune.logo)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 80, height: 80, alignment: .center)
        .accessibility(hidden: true)

      VStack(alignment: .leading, spacing: 12) {
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
  let systemSymbol: SFSymbol
  let color: Color

  @ViewBuilder var view: some View {
    HStack(alignment: .center, spacing: 30) {
      Image(systemSymbol: systemSymbol)
        .font(.largeTitle)
        .frame(width: 60)
        .accessibility(hidden: true)
        .foregroundColor(color)

      VStack(alignment: .leading) {
        Text(title)
          .font(.title3)
          .foregroundColor(.primary)

        Text(description)
          .font(.body)
          .foregroundColor(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
  }
}