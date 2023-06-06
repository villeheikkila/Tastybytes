import Charts
import PhotosUI
import SwiftUI

struct ProfileView: View {
  private let logger = getLogger(category: "ProfileView")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var friendManager: FriendManager
  @EnvironmentObject private var splashScreenManager: SplashScreenManager
  @Binding private var scrollToTop: Int
  @State private var profile: Profile
  @State private var profileSummary: ProfileSummary?
  @State private var selectedItem: PhotosPickerItem?
  private let topAnchor = "top"

  let isCurrentUser: Bool
  let isShownInFull: Bool

  init(profile: Profile, scrollToTop: Binding<Int>, isCurrentUser: Bool) {
    _scrollToTop = scrollToTop
    _profile = State(wrappedValue: profile)
    self.isCurrentUser = isCurrentUser
    isShownInFull = isCurrentUser || !profile.isPrivate
  }

  var showInFull: Bool {
    isShownInFull || friendManager.isFriend(profile)
  }

  var body: some View {
    CheckInListView(
      fetcher: .profile(profile),
      scrollToTop: $scrollToTop,
      onRefresh: {
        await getSummary()
      },
      topAnchor: topAnchor,
      emptyView: {},
      header: {
        profileSummarySection
          .listRowSeparator(.hidden)
          .id(topAnchor)
        VStack(spacing: 20) {
          if showInFull {
            ratingChart
            ratingSummary
            joinedAtSection
          } else {
            privateProfileSign
          }
          if !isCurrentUser,
             !friendManager.isFriend(profile) || friendManager.isPendingUserApproval(profile) != nil
          {
            friendActionSection
          }
        }
        .listRowSeparator(.hidden)
        if showInFull {
          links
        }
      }
    )
  }

  private var friendActionSection: some View {
    HStack {
      Spacer()
      Group {
        if friendManager.hasNoFriendStatus(friend: profile) {
          ProgressButton("Send Friend Request", action: { await friendManager.sendFriendRequest(receiver: profile.id) })
        } else if let friend = friendManager.isPendingUserApproval(profile) {
          ProgressButton(
            "Accept Friend Request",
            action: { await friendManager.updateFriendRequest(friend: friend, newStatus: .accepted) }
          )
        }
      }
      .font(.headline)
      .buttonStyle(ScalingButton())
      Spacer()
    }
  }

  private var avatar: some View {
    AvatarView(avatarUrl: profile.avatarUrl, size: 90, id: profile.id)
  }

  private var privateProfileSign: some View {
    VStack {
      HStack {
        Spacer()
        VStack(spacing: 8) {
          Image(systemSymbol: .eyeSlashCircle)
            .resizable()
            .scaledToFit()
            .frame(width: 32, height: 32)
            .accessibility(hidden: true)
          Text("Private profile")
            .font(.title3)
        }
        Spacer()
      }
      .padding(.top, 20)
    }
  }

  private var profileSummarySection: some View {
    HStack(alignment: .center, spacing: 20) {
      if showInFull {
        HStack {
          VStack {
            Text("Check-ins")
              .font(.caption).bold().textCase(.uppercase)
            Text(String(profileSummary?.totalCheckIns ?? 0))
              .font(.headline)
          }
          .padding(.leading, 30)
          .frame(width: 120)
        }
      }

      Spacer()

      VStack(alignment: .center) {
        if isCurrentUser {
          PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
          ) {
            avatar
          }
        } else {
          avatar
        }
      }
      .onChange(of: selectedItem) { _, newValue in
        Task { await uploadAvatar(userId: profileManager.id, newAvatar: newValue) }
      }

      Spacer()

      if showInFull {
        HStack {
          VStack {
            Text("Unique")
              .font(.caption).bold().textCase(.uppercase)
            Text(String(profileSummary?.uniqueCheckIns ?? 0))
              .font(.headline)
          }
          .padding(.trailing, 30)
          .frame(width: 100)
        }
      }
    }
    .padding(.top, 10)
    .task {
      if profileSummary == nil {
        await getSummary()
        await splashScreenManager.dismiss()
      }
    }
    .contextMenu {
      ShareLink("Share", item: NavigatablePath.profile(id: profile.id).url)
    }
  }

  private var ratingChart: some View {
    Chart {
      BarMark(
        x: .value("Rating", "0.5"),
        y: .value("Value", profileSummary?.rating1 ?? 0)
      )
      BarMark(
        x: .value("Rating", "1"),
        y: .value("Value", profileSummary?.rating2 ?? 0)
      )
      BarMark(
        x: .value("Rating", "1.5"),
        y: .value("Value", profileSummary?.rating3 ?? 0)
      )
      BarMark(
        x: .value("Rating", "2"),
        y: .value("Value", profileSummary?.rating4 ?? 0)
      )
      BarMark(
        x: .value("Rating", "2.5"),
        y: .value("Value", profileSummary?.rating5 ?? 0)
      )
      BarMark(
        x: .value("Rating", "3"),
        y: .value("Value", profileSummary?.rating6 ?? 0)
      )
      BarMark(
        x: .value("Rating", "3.5"),
        y: .value("Value", profileSummary?.rating7 ?? 0)
      )
      BarMark(
        x: .value("Rating", "4"),
        y: .value("Value", profileSummary?.rating8 ?? 0)
      )
      BarMark(
        x: .value("Rating", "4.5"),
        y: .value("Value", profileSummary?.rating9 ?? 0)
      )
      BarMark(
        x: .value("Rating", "5"),
        y: .value("Value", profileSummary?.rating10 ?? 0)
      )
    }
    .chartLegend(.hidden)
    .chartYAxis(.hidden)
    .chartXAxis {
      AxisMarks(position: .bottom) { _ in
        AxisValueLabel()
      }
    }
    .frame(height: 100)
    .padding([.leading, .trailing], 10)
  }

  private var ratingSummary: some View {
    HStack {
      VStack {
        Text("Unrated")
          .font(.caption).bold().textCase(.uppercase)
          .textCase(.uppercase)
        Text(String(profileSummary?.unrated ?? 0))
          .font(.headline)
      }
      VStack {
        Text("Average")
          .font(.caption).bold().textCase(.uppercase)
          .textCase(.uppercase)
        Text(String(profileSummary?.averageRating.toRatingString ?? "-"))
          .font(.headline)
      }
    }
  }

  private var joinedAtSection: some View {
    VStack {
      Text("Joined \(profile.joinedAt.customFormat(.date))").fontWeight(.medium)
      if profileManager.hasRole(.premium) {
        Text("Premium Member")
      }
    }
  }

  @ViewBuilder private var links: some View {
    Group {
      RouterLink(
        "Friends",
        systemSymbol: .personCropRectangleStack,
        screen: profileManager.profile == profile ? .currentUserFriends : .friends(profile)
      )
      RouterLink("Products", systemSymbol: .checkmarkRectangle, screen: .profileProducts(profile))
      RouterLink("Statistics", systemSymbol: .chartBarXaxis, screen: .profileStatistics(profile))
    }
    .font(.subheadline)
    .bold()
  }

  func uploadAvatar(userId: UUID, newAvatar: PhotosPickerItem?) async {
    guard let data = await newAvatar?.getJPEG() else { return }
    switch await repository.profile.uploadAvatar(userId: userId, data: data) {
    case let .success(avatarFile):
      profile = Profile(
        id: profile.id,
        preferredName: profile.preferredName,
        isPrivate: profile.isPrivate,
        avatarFile: avatarFile,
        joinedAt: profile.joinedAt
      )
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("uplodaing avatar for \(userId) failed: \(error.localizedDescription)")
    }
  }

  func getSummary() async {
    switch await repository.checkIn.getSummaryByProfileId(id: profile.id) {
    case let .success(summary):
      withAnimation(.easeIn) {
        profileSummary = summary
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("fetching profile data failed: \(error.localizedDescription)")
    }
  }
}
