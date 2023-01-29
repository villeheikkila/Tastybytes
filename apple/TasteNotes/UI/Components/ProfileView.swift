import Charts
import PhotosUI
import SwiftUI

struct ProfileView: View {
  @State private var profile: Profile
  @Binding var scrollToTop: Int
  @StateObject private var viewModel = ViewModel()
  @State private var resetView: Int = 0
  @EnvironmentObject private var toastManager: ToastManager
  @EnvironmentObject private var profileManager: ProfileManager

  init(profile: Profile, scrollToTop: Binding<Int>) {
    _profile = State(initialValue: profile)
    _scrollToTop = scrollToTop
  }

  var body: some View {
    CheckInListView(fetcher: .profile(profile), scrollToTop: $scrollToTop, resetView: $resetView) {
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
      ShareLink("Share", item: createLinkToScreen(.profile(id: profile.id)))
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
        Text(String(viewModel.profileSummary?.getFormattedAverageRating() ?? "-"))
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
    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
    .padding([.leading, .trailing], 5)
  }
}

extension ProfileView {
  @MainActor class ViewModel: ObservableObject {
    @Published var profileSummary: ProfileSummary?
    @Published var selectedItem: PhotosPickerItem?

    func uploadAvatar(userId: UUID, newAvatar: PhotosPickerItem?, onSuccess: @escaping (_ fileName: String) -> Void) {
      Task {
        if let imageData = try await newAvatar?.loadTransferable(type: Data.self),
           let image = UIImage(data: imageData),
           let data = image.jpegData(compressionQuality: 0.5)
        {
          switch await repository.profile.uploadAvatar(userId: userId, data: data) {
          case let .success(fileName):
            onSuccess(fileName)
          case let .failure(error):
            print(error)
          }
        }
      }
    }

    func getProfileData(userId: UUID) {
      Task {
        switch await repository.checkIn.getSummaryByProfileId(id: userId) {
        case let .success(summary):
          await MainActor.run {
            self.profileSummary = summary
          }
        case let .failure(error):
          print(error)
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
