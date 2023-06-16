import Charts
import OSLog
import PhotosUI
import SwiftUI

struct ProfileView: View {
    private let logger = Logger(category: "ProfileView")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackManager.self) private var feedbackManager
    @Environment(ProfileManager.self) private var profileManager
    @Environment(FriendManager.self) private var friendManager
    @Environment(SplashScreenManager.self) private var splashScreenManager
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
                if showInFull {
                    completeProfile
                } else {
                    privateProfile
                }
            }
        )
    }

    @ViewBuilder private var privateProfile: some View {
        privateProfileSign
        if !isCurrentUser,
           !friendManager.isFriend(profile) || friendManager.isPendingUserApproval(profile) != nil
        {
            friendActionSection
        }
    }

    @ViewBuilder private var completeProfile: some View {
        Group {
            ratingChart
            checkInImages
                .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
            ratingSummary
            joinedAtSection
            if !isCurrentUser,
               !friendManager.isFriend(profile) || friendManager.isPendingUserApproval(profile) != nil
            {
                friendActionSection
            }
        }.listRowSeparator(.hidden)
        links
    }

    private var friendActionSection: some View {
        HStack {
            Spacer()
            Group {
                if friendManager.hasNoFriendStatus(friend: profile) {
                    ProgressButton(
                        "Send Friend Request",
                        action: { await friendManager.sendFriendRequest(receiver: profile.id) }
                    )
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
                avatar
                    .overlay(alignment: .bottomTrailing) {
                        if isCurrentUser {
                            PhotosPicker(selection: $selectedItem,
                                         matching: .images,
                                         photoLibrary: .shared())
                            {
                                Image(systemSymbol: .pencilCircleFill)
                                    .symbolRenderingMode(.multicolor)
                                    .font(.system(size: 24))
                                    .foregroundColor(.accentColor)
                            }
                            .buttonStyle(.borderless)
                        }
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
        .listRowSeparator(.hidden)
        .id(topAnchor)
        .task {
            if profileSummary == nil {
                await getSummary()
                await splashScreenManager.dismiss()
            }
        }
        .contextMenu {
            ProfileShareLinkView(profile: profile)
        }
    }

    private var ratingChart: some View {
        RatingChart(profile: profile, profileSummary: profileSummary)
    }

    private var ratingSummary: some View {
        HStack {
            Spacer()
            VStack {
                Text("Unrated")
                    .font(.caption).bold().textCase(.uppercase)
                    .textCase(.uppercase)
                Text(String(profileSummary?.unrated ?? 0))
                    .font(.headline)
            }
            Spacing(width: 12)
            Divider()
            Spacing(width: 12)
            VStack {
                Text("Average")
                    .font(.caption).bold().textCase(.uppercase)
                    .textCase(.uppercase)
                Text(String(profileSummary?.averageRating.toRatingString ?? "-"))
                    .font(.headline)
            }
            Spacer()
        }
    }

    private var joinedAtSection: some View {
        HStack {
            Spacer()
            Text("Joined \(profile.joinedAt.customFormat(.date))")
                .fontWeight(.medium)
            Spacer()
        }
    }

    @ViewBuilder private var checkInImages: some View {
        Section {
            CheckInImages(profile: profile)
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
            if isCurrentUser {
                RouterLink("Locations", systemSymbol: .map, screen: .profileLocations(profile))
            }
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
            logger.error("uplodaing avatar for \(userId) failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func getSummary() async {
        switch await repository.checkIn.getSummaryByProfileId(id: profile.id) {
        case let .success(summary):
            await MainActor.run {
                withAnimation(.easeIn) {
                    profileSummary = summary
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("fetching profile data failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct CheckInImages: View {
    private let logger = Logger(category: "CheckInImages")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackManager.self) private var feedbackManager
    @Environment(Router.self) private var router
    @State private var checkInImages = [CheckIn.Image]()
    @State private var isLoading = false
    @State private var page = 0
    private let pageSize = 10

    func getPagination(page: Int, size: Int) -> (Int, Int) {
        let limit = size + 1
        let from = page * limit
        let to = from + size
        return (from, to)
    }

    let profile: Profile

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(checkInImages) { checkInImage in
                    CheckInImageCell(checkInImage: checkInImage)
                        .onTapGesture {
                            router.fetchAndNavigateTo(repository, .checkIn(id: checkInImage.id))
                        }
                        .onAppear {
                            if checkInImage == checkInImages.last, isLoading != true {
                                Task {
                                    await fetchImages()
                                }
                            }
                        }
                }
            }
        }
        .task {
            await fetchImages()
        }
    }

    func fetchImages() async {
        let (from, to) = getPagination(page: page, size: pageSize)
        isLoading = true

        switch await repository.checkIn.getCheckInImages(id: profile.id, from: from, to: to) {
        case let .success(checkIns):
            await MainActor.run {
                withAnimation {
                    self.checkInImages.append(contentsOf: checkIns)
                }
                page += 1
                isLoading = false
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger
                .error(
                    "Fetching check-in images failed. Description: \(error.localizedDescription). Error: \(error) (\(#file):\(#line))"
                )
        }
    }
}

extension CheckInImages {
    struct CheckInImageCell: View {
        let checkInImage: CheckIn.Image

        var body: some View {
            HStack {
                AsyncImage(url: checkInImage.imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(4)
                        .contentShape(Rectangle())
                } placeholder: {
                    BlurHashPlaceholder(blurHash: checkInImage.blurHash, height: 100)
                }
                .frame(width: 100, height: 100)
            }
        }
    }
}

struct RatingChart: View {
    @Environment(Router.self) private var router
    let profile: Profile
    let profileSummary: ProfileSummary?

    var body: some View {
        Section {
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
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .onTapGesture { location in
                            updateSelectedRating(at: location,
                                                 proxy: proxy,
                                                 geometry: geometry)
                        }
                }
            }
            .frame(height: 100)
        }
    }

    private func updateSelectedRating(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        let xPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        guard let value: String = proxy.value(atX: xPosition), let rating = Double(value) else {
            return
        }
        router.navigate(screen: .profileProductsByFilter(profile, Product.Filter(rating: rating)))
    }
}
