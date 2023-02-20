import Charts
import PhotosUI
import SwiftUI

struct ProfileView: View {
  @StateObject private var viewModel: ViewModel
  @Binding private var scrollToTop: Int
  @State private var resetView: Int = 0
  @EnvironmentObject private var toastManager: ToastManager
  @EnvironmentObject private var profileManager: ProfileManager

  init(_ client: Client, profile: Profile, scrollToTop: Binding<Int>, isCurrentUser: Bool) {
    _scrollToTop = scrollToTop
    _viewModel = StateObject(wrappedValue: ViewModel(client, profile: profile, isCurrentUser: isCurrentUser))
  }

  var showInFull: Bool {
    viewModel.isShownInFull || profileManager.hasFriendByUserId(userId: viewModel.profile.id)
  }

  var body: some View {
    CheckInListView(
      viewModel.client,
      fetcher: .profile(viewModel.profile),
      scrollToTop: $scrollToTop,
      resetView: $resetView,
      onRefresh: {
        viewModel.getSummary()
      }
    ) {
      VStack(spacing: 20) {
        profileSummary
        if showInFull {
          ratingChart
          ratingSummary
        } else {
          privateProfileSign
        }
        if !viewModel.isCurrentUser,
           !profileManager.hasFriendByUserId(userId: viewModel.profile.id)
        {
          sendFriendRequestButton
        }
      }
      .listRowSeparator(.hidden)
      links
    }
  }

  private var sendFriendRequestButton: some View {
    HStack {
      Spacer()
      Button(action: {
        profileManager.sendFriendRequest(receiver: viewModel.profile.id) {
          toastManager.toggle(.success("Friend Request Sent!"))
        }
      }) {
        Text("Send Friend Request")
          .font(.system(size: 14, weight: .bold, design: .default))
      }.buttonStyle(ScalingButton())
      Spacer()
    }
  }

  private var avatar: some View {
    AvatarView(avatarUrl: viewModel.profile.avatarUrl, size: 90, id: viewModel.profile.id)
  }

  private var privateProfileSign: some View {
    VStack {
      HStack {
        Spacer()
        VStack(spacing: 8) {
          Image(systemName: "eye.slash.circle")
            .imageScale(.large)
          Text("Private profile")
            .font(.system(size: 24))
        }
        Spacer()
      }
      .padding(.top, 20)
    }
  }

  private var profileSummary: some View {
    HStack(alignment: .center, spacing: 20) {
      if showInFull {
        HStack {
          VStack {
            Text("Check-ins")
              .font(.system(size: 12, weight: .medium, design: .default)).textCase(.uppercase)
            Text(String(viewModel.profileSummary?.totalCheckIns ?? 0))
              .font(.system(size: 16, weight: .bold, design: .default))
          }
          .padding(.leading, 30)
          .frame(width: 100)
        }
      }

      Spacer()

      VStack(alignment: .center) {
        if showInFull {
          PhotosPicker(
            selection: $viewModel.selectedItem,
            matching: .images,
            photoLibrary: .shared()
          ) {
            avatar
          }
        } else {
          avatar
        }
      }
      .onChange(of: viewModel.selectedItem) { newValue in
        viewModel.uploadAvatar(userId: profileManager.getId(), newAvatar: newValue)
      }

      Spacer()

      if showInFull {
        HStack {
          VStack {
            Text("Unique")
              .font(.system(size: 12, weight: .medium, design: .default)).textCase(.uppercase)
            Text(String(viewModel.profileSummary?.uniqueCheckIns ?? 0))
              .font(.system(size: 16, weight: .bold, design: .default))
          }
          .padding(.trailing, 30)
          .frame(width: 100)
        }
      }
    }
    .padding(.top, 10)
    .task {
      viewModel.getSummary()
    }
    .contextMenu {
      ShareLink("Share", item: NavigatablePath.profile(id: viewModel.profile.id).url)
    }
  }

  private var ratingChart: some View {
    Chart {
      LineMark(
        x: .value("Rating", "0.5"),
        y: .value("Value", viewModel.profileSummary?.rating1 ?? 0)
      )
      LineMark(
        x: .value("Rating", "1"),
        y: .value("Value", viewModel.profileSummary?.rating2 ?? 0)
      )
      LineMark(
        x: .value("Rating", "1.5"),
        y: .value("Value", viewModel.profileSummary?.rating3 ?? 0)
      )
      LineMark(
        x: .value("Rating", "2"),
        y: .value("Value", viewModel.profileSummary?.rating4 ?? 0)
      )
      LineMark(
        x: .value("Rating", "2.5"),
        y: .value("Value", viewModel.profileSummary?.rating5 ?? 0)
      )
      LineMark(
        x: .value("Rating", "3"),
        y: .value("Value", viewModel.profileSummary?.rating6 ?? 0)
      )
      LineMark(
        x: .value("Rating", "3.5"),
        y: .value("Value", viewModel.profileSummary?.rating7 ?? 0)
      )
      LineMark(
        x: .value("Rating", "4"),
        y: .value("Value", viewModel.profileSummary?.rating8 ?? 0)
      )
      LineMark(
        x: .value("Rating", "4.5"),
        y: .value("Value", viewModel.profileSummary?.rating9 ?? 0)
      )
      LineMark(
        x: .value("Rating", "5"),
        y: .value("Value", viewModel.profileSummary?.rating10 ?? 0)
      )
    }
    .chartLegend(.hidden)
    .chartYAxis(.hidden)
    .frame(height: 100)
    .padding([.leading, .trailing], 10)
  }

  private var ratingSummary: some View {
    HStack {
      VStack {
        Text("Unrated")
          .font(.system(size: 12, weight: .medium, design: .default))
          .textCase(.uppercase)
        Text(String(viewModel.profileSummary?.unrated ?? 0))
          .font(.system(size: 16, weight: .bold, design: .default))
      }
      VStack {
        Text("Average")
          .font(.system(size: 12, weight: .medium, design: .default))
          .textCase(.uppercase)
        Text(String(viewModel.profileSummary?.averageRating.toRatingString ?? "-"))
          .font(.system(size: 16, weight: .bold, design: .default))
      }
    }
  }

  @ViewBuilder
  private var links: some View {
    NavigationLink(value: Route.friends(viewModel.profile)) {
      Text("Friends")
        .font(.system(size: 16, weight: .medium, design: .default))
    }
    .listRowBackground(Color(.secondarySystemBackground))
    NavigationLink(value: Route.profileProducts(viewModel.profile)) {
      Text("Products")
        .font(.system(size: 16, weight: .medium, design: .default))
    }
    .listRowBackground(Color(.secondarySystemBackground))
    NavigationLink(value: Route.profileStatistics(viewModel.profile)) {
      Text("Statistics")
        .font(.system(size: 16, weight: .medium, design: .default))
    }
    .listRowBackground(Color(.secondarySystemBackground))
  }
}
