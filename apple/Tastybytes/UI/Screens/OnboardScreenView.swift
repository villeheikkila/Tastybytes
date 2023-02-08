import SwiftUI

struct OnboardScreenView: View {
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
  }

  var appIcon: some View {
      HStack(spacing: 12) {
      Image(AppIcon.ramune.logo)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 80, height: 80, alignment: .center)

      VStack(alignment: .leading, spacing: 8) {
        Text(Config.appName)
          .font(.title)
          .fontWeight(.bold)

        Text("The definite app for storing and sharing tasting notes")
          .foregroundColor(.secondary)
      }
    }
  }

  let features: [FeatureItem] = [FeatureItem(
    title: "Activity Feed",
    description: "Find out what your friends have been tasting",
    systemName: "list.star",
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
    description: "See overview on your tasting habits",
    systemName: "chart.xyaxis.line",
    color: .orange
  )]
}

extension OnboardScreenView {
  struct FeatureItem: Hashable {
    let title: String
    let description: String
    let systemName: String
    let color: Color

    @ViewBuilder
    var view: some View {
      HStack(alignment: .center, spacing: 8) {
        Image(systemName: systemName)
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
}

struct OnboardScreenView_Previews: PreviewProvider {
  static var previews: some View {
    OnboardScreenView()
  }
}
