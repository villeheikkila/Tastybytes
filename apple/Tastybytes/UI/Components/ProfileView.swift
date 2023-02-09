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
        if viewModel.isPublic {
          ratingChart
          ratingSummary
          links
        } else {
          privateProfileSign
        }
        if !viewModel.isCurrentUser,
           !profileManager.hasFriendByUserId(userId: viewModel.profile.id)
        {
          sendFriendRequestButton
        }
      }
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
      if viewModel.isPublic {
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
        if viewModel.isCurrentUser {
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

      if viewModel.isPublic {
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

  private var links: some View {
    VStack {
      NavigationLink(value: Route.friends(viewModel.profile)) {
        HStack {
          Text("Friends")
            .font(.system(size: 16, weight: .medium, design: .default))
          Spacer()
          Image(systemName: "chevron.forward")
        }
        .padding([.leading, .trailing], 20)
        .padding([.top], 10)
        .contentShape(Rectangle())
      }
      Divider()
      NavigationLink(value: Route.profileProducts(viewModel.profile)) {
        HStack {
          Text("Products")
            .font(.system(size: 16, weight: .medium, design: .default))
          Spacer()
          Image(systemName: "chevron.forward")
        }
        .padding([.leading, .trailing], 20)
        .padding([.bottom], 10)
        .contentShape(Rectangle())
      }
    }
    .background(Color(.tertiarySystemBackground))
    .cornerRadius(10)
    .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 0)
  }
}

extension ProfileView {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ProfileView")
    let client: Client
    @Published var profile: Profile
    @Published var profileSummary: ProfileSummary?
    @Published var selectedItem: PhotosPickerItem?

    let isCurrentUser: Bool
    let isPublic: Bool

    init(_ client: Client, profile: Profile, isCurrentUser: Bool) {
      self.client = client
      self.profile = profile
      self.isCurrentUser = isCurrentUser
      isPublic = isCurrentUser || !profile.isPrivate
    }

    func uploadAvatar(userId: UUID, newAvatar: PhotosPickerItem?) {
      Task {
        if let imageData = try await newAvatar?.loadTransferable(type: Data.self),
           let image = UIImage(data: imageData),
           let data = image.jpegData(compressionQuality: 0.1)
        {
          switch await client.profile.uploadAvatar(userId: userId, data: data) {
          case let .success(fileName):
            profile = Profile(
              id: profile.id,
              preferredName: profile.preferredName,
              isPrivate: profile.isPrivate,
              avatarUrl: fileName
            )
          case let .failure(error):
            logger
              .error(
                "uplodaing avatar for \(userId) failed: \(error.localizedDescription)"
              )
          }
        }
      }
    }

    func getSummary() {
      Task {
        switch await client.checkIn.getSummaryByProfileId(id: profile.id) {
        case let .success(summary):
          withAnimation {
            self.profileSummary = summary
          }
        case let .failure(error):
          logger
            .error(
              "fetching profile data for \(self.profile.id) failed: \(error.localizedDescription)"
            )
        }
      }
    }
  }
}

struct ScalingButton: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.all, 10)
      .background(.blue)
      .foregroundColor(.white)
      .clipShape(Rectangle())
      .cornerRadius(8)
      .scaleEffect(configuration.isPressed ? 1.05 : 1)
      .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
  }
}
