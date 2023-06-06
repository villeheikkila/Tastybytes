import SwiftUI

struct ActivityScreen: View {
  @Binding var scrollToTop: Int
  @EnvironmentObject private var router: Router

  let navigateToDiscoverTab: () -> Void

  var body: some View {
    CheckInListView(
      fetcher: .activityFeed,
      scrollToTop: $scrollToTop,
      onRefresh: {},
      showContentUnavailableView: true,
      emptyView: {},
      header: {}
    )
  }

  var onboardingEmptyView: some View {
    Group {
      VStack {
        HStack {
          Spacer()
          Text("Your activity feed is empty!")
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding()
          Spacer()
        }
        HStack {
          Spacer()
          Text("Get started by checking in or adding friends.")
            .font(.headline)
            .multilineTextAlignment(.center)
            .padding()
          Spacer()
        }
      }
      Group {
        Button("Complete Your First Check-in!", action: {
          navigateToDiscoverTab()
        })
        .fontWeight(.bold)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)

        Button("Add Friends", action: {
          router.navigate(screen: .currentUserFriends)
        })
        .fontWeight(.bold)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.green)
        .foregroundColor(.white)
        .cornerRadius(10)
      }
    }
    .listRowBackground(Color.clear)
    .listRowSeparator(.hidden)
  }
}
