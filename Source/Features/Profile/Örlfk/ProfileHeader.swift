import Charts
import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

@MainActor
struct ProfileHeader: View {
    private let logger = Logger(category: "ProfileHeader")
    @Environment(\.repository) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(Router.self) private var router
    @State private var profile: Profile
    @State private var profileSummary: ProfileSummary?
    @State private var alertError: AlertError?
    @State private var checkInImages = [CheckIn.Image]()
    @State private var isLoading = false
    @State private var loadImagesTask: Task<Void, Never>?
    @State private var page = 0
    @Binding var refreshId: Int
    @State private var resultId: Int?
    private let pageSize = 10

    private let isCurrentUser: Bool
    private let isShownInFull: Bool
    let topAnchor: Int

    init(profile: Profile, refreshId: Binding<Int>, isCurrentUser: Bool, topAnchor: Int) {
        _profile = State(wrappedValue: profile)
        self.isCurrentUser = isCurrentUser
        self.topAnchor = topAnchor
        _refreshId = refreshId
        isShownInFull = isCurrentUser || !profile.isPrivate
    }

    var showInFull: Bool {
        isShownInFull || friendEnvironmentModel.isFriend(profile)
    }

    var body: some View {
        VStack {
            ProfileHeaderAvatarSection(
                profile: $profile,
                isCurrentUser: isCurrentUser,
                showInFull: showInFull,
                profileSummary: profileSummary
            )
            .id(topAnchor)
            if showInFull {
                RatingChartView(profile: profile, profileSummary: profileSummary)
                    .padding(.vertical, 10)
                ProfileCheckInImagesSection(checkInImages: checkInImages, isLoading: isLoading, onLoadMore: {
                    loadImagesTask = Task {
                        await fetchImages()
                    }
                })
                .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
                ProfileSummarySection(profile: profile, profileSummary: profileSummary)
                ProfileJoinedAtSection(joinedAt: profile.joinedAt)
                sendFriendRequestSection
                ProfileLinksSection(profile: profile, isCurrentUser: isCurrentUser)
            } else {
                PrivateProfileSign()
                sendFriendRequestSection
            }
        }
        .task(id: refreshId) { [refreshId] in
            guard refreshId != resultId else { return }
            logger.info("Refreshing profile screen with id: \(refreshId)")
            await getProfileData()
            resultId = refreshId
        }
        .alertError($alertError)
        .onDisappear {
            loadImagesTask?.cancel()
        }
    }

    @ViewBuilder private var sendFriendRequestSection: some View {
        if !isCurrentUser,
           !friendEnvironmentModel.isFriend(profile) || friendEnvironmentModel
               .isPendingUserApproval(profile) != nil
        {
            ProfileFriendActionSection(profile: profile)
        }
    }

    func getProfileData() async {
        async let summaryPromise = repository.checkIn.getSummaryByProfileId(id: profile.id)
        async let imagesPromise = repository.checkIn.getCheckInImages(by: .profile(profile), from: 0, to: pageSize)

        let (summaryResult, imagesResult) = (
            await summaryPromise,
            await imagesPromise
        )

        switch summaryResult {
        case let .success(summary):
            withAnimation(.easeIn) {
                profileSummary = summary
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("fetching profile data failed. Error: \(error) (\(#file):\(#line))")
        }

        switch imagesResult {
        case let .success(checkIns):
            withAnimation {
                self.checkInImages.append(contentsOf: checkIns)
            }
            page += 1
            isLoading = false
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger
                .error(
                    "Fetching check-in images failed. Description: \(error.localizedDescription). Error: \(error) (\(#file):\(#line))"
                )
        }
    }

    func fetchImages() async {
        let (from, to) = getPagination(page: page, size: pageSize)
        isLoading = true

        switch await repository.checkIn.getCheckInImages(by: .profile(profile), from: from, to: to) {
        case let .success(checkIns):
            withAnimation {
                self.checkInImages.append(contentsOf: checkIns)
            }
            page += 1
            isLoading = false
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger
                .error(
                    "Fetching check-in images failed. Description: \(error.localizedDescription). Error: \(error) (\(#file):\(#line))"
                )
        }
    }
}
