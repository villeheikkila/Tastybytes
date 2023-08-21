import Charts
import EnvironmentModels
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct ProfileView: View {
    private let logger = Logger(category: "ProfileView")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(Router.self) private var router
    @Environment(SplashScreenEnvironmentModel.self) private var splashScreenEnvironmentModel
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
        isShownInFull || friendEnvironmentModel.isFriend(profile)
    }

    var body: some View {
        CheckInListView(
            fetcher: .profile(profile),
            scrollToTop: $scrollToTop,
            onRefresh: {
                await getSummary()
            },
            topAnchor: topAnchor,
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
           !friendEnvironmentModel.isFriend(profile) || friendEnvironmentModel.isPendingUserApproval(profile) != nil
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
               !friendEnvironmentModel.isFriend(profile) || friendEnvironmentModel.isPendingUserApproval(profile) != nil
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
                if friendEnvironmentModel.hasNoFriendStatus(friend: profile) {
                    ProgressButton(
                        "Send Friend Request",
                        action: { await friendEnvironmentModel.sendFriendRequest(receiver: profile.id) }
                    )
                } else if let friend = friendEnvironmentModel.isPendingUserApproval(profile) {
                    ProgressButton(
                        "Accept Friend Request",
                        action: {
                            await friendEnvironmentModel.updateFriendRequest(friend: friend, newStatus: .accepted)
                        }
                    )
                }
            }
            .font(.headline)
            .buttonStyle(ScalingButton())
            Spacer()
        }
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
        HStack(alignment: .center) {
            if showInFull {
                Spacer()
                CheckInStatisticView(title: "Check-ins", subtitle: String(profileSummary?.totalCheckIns ?? 0)) {
                    router.navigate(screen: .profileProducts(profile))
                }
            }
            Spacer()
            VStack(alignment: .center) {
                AvatarView(avatarUrl: profile.avatarUrl, size: 90, id: profile.id)
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
                Task { await uploadAvatar(userId: profileEnvironmentModel.id, newAvatar: newValue) }
            }
            Spacer()
            if showInFull {
                CheckInStatisticView(title: "Unique", subtitle: String(profileSummary?.uniqueCheckIns ?? 0)) {
                    router.navigate(screen: .profileProducts(profile))
                }
                Spacer()
            }
        }
        .listRowSeparator(.hidden)
        .id(topAnchor)
        .task {
            if profileSummary == nil {
                await getSummary()
                await splashScreenEnvironmentModel.dismiss()
            }
        }
        .contextMenu {
            ProfileShareLinkView(profile: profile)
        }
    }

    private var ratingChart: some View {
        RatingChartView(profile: profile, profileSummary: profileSummary)
    }

    private var ratingSummary: some View {
        HStack {
            Spacer()
            CheckInStatisticView(title: "Unrated", subtitle: String(profileSummary?.unrated ?? 0)) {
                router.navigate(screen: .profileProductsByFilter(profile, Product.Filter(onlyUnrated: true)))
            }
            Spacing(width: 12)
            Divider()
            Spacing(width: 12)
            CheckInStatisticView(title: "Average", subtitle: profileSummary?.averageRating.toRatingString ?? "-") {
                router.navigate(screen: .profileProductsByFilter(profile, Product.Filter(sortBy: .highestRated)))
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
            CheckInImagesView(queryType: .profile(profile))
        }
    }

    @ViewBuilder private var links: some View {
        Group {
            RouterLink(
                "Friends",
                systemSymbol: .personCropRectangleStack,
                screen: profileEnvironmentModel.profile == profile ? .currentUserFriends : .friends(profile)
            )
            RouterLink("Check-ins", systemSymbol: .checkmarkRectangle, screen: .profileProducts(profile))
            RouterLink("Statistics", systemSymbol: .chartBarXaxis, screen: .profileStatistics(profile))
            RouterLink("Wishlist", systemSymbol: .heart, screen: .profileWishlist(profile))
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
            feedbackEnvironmentModel.toggle(.error(.unexpected))
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
            feedbackEnvironmentModel.toggle(.error(.unexpected))
            logger.error("fetching profile data failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct CheckInStatisticView: View {
    let title: String
    let subtitle: String
    let onTap: () -> Void

    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .bold()
                .textCase(.uppercase)
            Text(subtitle)
                .font(.headline)
        }
        .onTapGesture {
            onTap()
        }
    }
}
