import Charts
import GoTrue
import PhotosUI
import SwiftUI

struct ProfileScreenView: View {
  @State private var profile: Profile
  @StateObject private var viewModel = ViewModel()
  @EnvironmentObject private var toastManager: ToastManager
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var router: Router

  init(profile: Profile) {
    _profile = State(initialValue: profile)
  }

  var body: some View {
    InfiniteScrollView(
      data: $viewModel.checkIns,
      isLoading: $viewModel.isLoading,
      loadMore: { viewModel.fetchMoreCheckIns(userId: profile.id) },
      refresh: {
        viewModel.refresh(userId: profile.id)
      },
      content: {
        CheckInCardView(checkIn: $0,
                        loadedFrom: .profile(profile),
                        onDelete: { checkIn in viewModel.onCheckInDelete(checkIn: checkIn)
                        },
                        onUpdate: { checkIn in viewModel.onCheckInUpdate(checkIn: checkIn) })
      },
      header: {
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
    )
    .navigationTitle(profile.preferredName)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      toolbarContent
    }
  }

  var sendFriendRequestButton: some View {
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

  var avatar: some View {
    AvatarView(avatarUrl: profile.getAvatarURL(), size: 90, id: profile.id)
  }

  var profileSummary: some View {
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
      }.onChange(of: viewModel.selectedItem) { newValue in
        viewModel.uploadAvatar(newAvatar: newValue) {
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

  var ratingChart: some View {
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

  var ratingSummary: some View {
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

  var links: some View {
    VStack {
      HStack {
        Text("Friends")
          .font(.system(size: 16, weight: .medium, design: .default))
        Spacer()
        Image(systemName: "chevron.forward")
      }
      .padding([.leading, .trailing], 20)
      .padding([.top], 10)
      .contentShape(Rectangle())
      .onTapGesture {
        router.navigate(to: Route.friends(profile), resetStack: false)
      }
      Divider()
      HStack {
        Text("Products")
          .font(.system(size: 16, weight: .medium, design: .default))
        Spacer()
        Image(systemName: "chevron.forward")
      }
      .padding([.leading, .trailing], 20)
      .padding([.bottom], 10)
      .contentShape(Rectangle())
      .onTapGesture {
        router.navigate(to: Route.profileProducts(profile), resetStack: false)
      }
    }
    .background(Color(.tertiarySystemBackground))
    .cornerRadius(10)
    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
    .padding([.leading, .trailing], 5)
  }

  @ToolbarContentBuilder
  var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarLeading) {
      NavigationLink(value: Route.currentUserFriends) {
        Image(systemName: "person.2").imageScale(.large)
      }
    }
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      NavigationLink(value: Route.settings) {
        Image(systemName: "gear").imageScale(.large)
      }
    }
  }
}

extension ProfileScreenView {
  @MainActor class ViewModel: ObservableObject {
    @Published var checkIns = [CheckIn]()
    @Published var profileSummary: ProfileSummary?
    @Published var isLoading = false
    @Published var selectedItem: PhotosPickerItem?

    let pageSize = 10
    var page = 0

    func refresh(userId: UUID) {
      page = 0
      checkIns = []
      fetchMoreCheckIns(userId: userId)
    }

    func onCheckInUpdate(checkIn: CheckIn) {
      if let index = checkIns.firstIndex(where: { $0.id == checkIn.id }) {
        DispatchQueue.main.async {
          self.checkIns[index] = checkIn
        }
      }
    }

    func onCheckInDelete(checkIn: CheckIn) {
      checkIns.remove(object: checkIn)
    }

    func fetchMoreCheckIns(userId: UUID) {
      let (from, to) = getPagination(page: page, size: pageSize)

      Task {
        await MainActor.run {
          self.isLoading = true
        }

        switch await repository.checkIn.getByProfileId(id: userId, from: from, to: to) {
        case let .success(checkIns):
          await MainActor.run {
            self.checkIns.append(contentsOf: checkIns)
            self.page += 1
            self.isLoading = false
          }
        case let .failure(error):
          print(error)
        }
      }
    }

    func uploadAvatar(newAvatar: PhotosPickerItem?, onSuccess: @escaping (_ fileName: String) -> Void) {
      Task {
        if let imageData = try await newAvatar?.loadTransferable(type: Data.self),
           let image = UIImage(data: imageData),
           let data = image.jpegData(compressionQuality: 0.5)
        {
          switch await repository.profile.uploadAvatar(userId: repository.auth.getCurrentUserId(), data: data) {
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
