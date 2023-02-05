import Charts
import PhotosUI
import SwiftUI

struct ProfileView: View {
  @State private var profile: Profile
  @Binding private var scrollToTop: Int
  @StateObject private var viewModel: ViewModel
  @State private var resetView: Int = 0
  @EnvironmentObject private var toastManager: ToastManager
  @EnvironmentObject private var profileManager: ProfileManager

  init(_ client: Client, profile: Profile, scrollToTop: Binding<Int>) {
    _profile = State(initialValue: profile)
    _scrollToTop = scrollToTop
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

  var body: some View {
    CheckInListView(
      viewModel.client,
      fetcher: .profile(profile),
      scrollToTop: $scrollToTop,
      resetView: $resetView,
      onRefresh: {}
    ) {
      VStack(spacing: 20) {
        profileSummary
        ratingChart
        ratingSummary
        if profileManager.getId() != profile.id,
           !profileManager.hasFriendByUserId(userId: profile.id)
        {
          sendFriendRequestButton
        }
        links
      }
    }
  }

  private var sendFriendRequestButton: some View {
    HStack {
      Spacer()
      Button(action: {
        profileManager.sendFriendRequest(receiver: profile.id) {
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
    AvatarView(avatarUrl: profile.getAvatarURL(), size: 90, id: profile.id)
  }

  private var profileSummary: some View {
    HStack(alignment: .center, spacing: 20) {
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

      Spacer()

      VStack(alignment: .center) {
        if profile.id == profileManager.getId() {
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
        viewModel.uploadAvatar(userId: profileManager.getId(), newAvatar: newValue) {
          fileName in profile.avatarUrl = fileName
        }
      }

      Spacer()

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
    .padding(.top, 10)
    .task {
      viewModel.getProfileData(userId: profile.id)
    }
    .contextMenu {
      ShareLink("Share", item: NavigatablePath.profile(id: profile.id).url)
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
      NavigationLink(value: Route.friends(profile)) {
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
      NavigationLink(value: Route.profileProducts(profile)) {
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
    @Published var profileSummary: ProfileSummary?
    @Published var selectedItem: PhotosPickerItem?

    init(_ client: Client) {
      self.client = client
    }

    func uploadAvatar(userId: UUID, newAvatar: PhotosPickerItem?, onSuccess: @escaping (_ fileName: String) -> Void) {
      Task {
        if let imageData = try await newAvatar?.loadTransferable(type: Data.self),
           let image = UIImage(data: imageData),
           let data = image.jpegData(compressionQuality: 0.1)
        {
          switch await client.profile.uploadAvatar(userId: userId, data: data) {
          case let .success(fileName):
            onSuccess(fileName)
          case let .failure(error):
            logger
              .error(
                "uplodaing avatar for \(userId) failed: \(error.localizedDescription)"
              )
          }
        }
      }
    }

    func getProfileData(userId: UUID) {
      Task {
        switch await client.checkIn.getSummaryByProfileId(id: userId) {
        case let .success(summary):
          withAnimation {
            self.profileSummary = summary
          }
        case let .failure(error):
          logger
            .error(
              "fetching profile data for \(userId) failed: \(error.localizedDescription)"
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
