import Charts
import Components

import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct ProfileView: View {
    private let logger = Logger(category: "ProfileView")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(ProfileModel.self) private var profileModel
    @Environment(FeedbackModel.self) private var feedbackModel
    @Environment(AppModel.self) private var appModel
    @State private var state: ScreenState = .loading
    @State private var checkIns = [CheckIn.Joined]()
    @State private var profile: Profile.Saved
    @State private var profileSummary: Profile.Summary?
    @State private var checkInImages = [ImageEntity.CheckInId]()
    @State private var isLoading = false
    @State private var isRefreshing = false
    @State private var imagePage = 0
    @State private var showAvatarPicker = false
    @State private var selectedAvatarImage: PhotosPickerItem?

    private let topAnchor = 0
    private let isCurrentUser: Bool

    init(profile: Profile.Saved, isCurrentUser: Bool) {
        _profile = State(initialValue: profile)
        self.isCurrentUser = isCurrentUser
    }

    private var showInFull: Bool {
        isCurrentUser || !profile.isPrivate || profileModel.isFriend(profile)
    }

    var body: some View {
        List {
            if state.isPopulated {
                content
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .animation(.default, value: checkIns)
        .animation(.easeIn, value: profile)
        .refreshable {
            await initialize(isRefresh: true)
        }
        .checkInCardLoadedFrom(.profile(profile))
        .overlay {
            ScreenStateOverlayView(state: state) {
                await initialize(isRefresh: true)
            }
        }
        .photosPicker(isPresented: $showAvatarPicker, selection: $selectedAvatarImage, matching: .images, photoLibrary: .shared())
        .initialTask {
            await initialize()
        }
        .task(id: selectedAvatarImage) {
            guard let selectedAvatarImage, let data = await selectedAvatarImage.getImageData() else { return }
            guard let image = UIImage(data: data) else { return }
            router.open(.fullScreenCover(.cropImage(image: image, onSubmit: { image in
                guard let image else { return }
                Task {
                    guard let data = image.jpegData(compressionQuality: 0.7) else { return }
                    await profileModel.uploadAvatar(data: data)
                    profile = profileModel.profile
                }
            })))
        }
    }

    @ViewBuilder private var content: some View {
        Group {
            ProfileHeaderAvatarSection(
                showAvatarPicker: $showAvatarPicker, profile: $profile,
                isCurrentUser: isCurrentUser,
                showInFull: showInFull,
                profileSummary: profileSummary
            )
            .id(topAnchor)
            if showInFull {
                RatingChartView(profile: profile, profileSummary: profileSummary)
                if !checkInImages.isEmpty {
                    CheckInImagesSection(checkInImages: checkInImages, page: $imagePage, onLoadMore: fetchImages)
                }
                ProfileSummarySection(profile: profile, profileSummary: profileSummary)
                ProfileJoinedAtSection(joinedAt: profile.joinedAt)
                sendFriendRequestSection
                ProfileLinksSection(profile: profile, isCurrentUser: isCurrentUser)
            } else {
                PrivateProfileSign()
                sendFriendRequestSection
            }
        }
        .listRowSeparator(.hidden)
        CheckInListContentView(checkIns: $checkIns, onLoadMore: {
            await fetchFeedItems()
        })
        CheckInListLoadingIndicatorView(isLoading: $isLoading, isRefreshing: $isRefreshing)
    }

    @ViewBuilder private var sendFriendRequestSection: some View {
        if !isCurrentUser, profileModel.hasNoFriendStatus(friend: profile) || (profileModel.isPendingCurrentUserApproval(profile) != nil) {
            ProfileFriendActionSection(profile: profile)
        }
    }

    private func initialize(isRefresh: Bool = false) async {
        let startTime = DispatchTime.now()
        async let checkInsPromise: Void = fetchFeedItems(reset: true)
        async let summaryPromise = repository.checkIn.getSummaryByProfileId(id: profile.id)
        async let imagesPromise = repository.checkIn.getCheckInImages(by: .profile(profile.id), from: 0, to: appModel.rateControl.checkInPageSize)
        do {
            let (summaryResult, imagesResult) = try await (summaryPromise, imagesPromise)
            imagePage += 1
            withAnimation {
                profileSummary = summaryResult
                imagePage = 1
                checkInImages = imagesResult
                isLoading = false
                state = .populated
            }
        } catch {
            state = .getState(error: error, withHaptics: isRefresh, feedbackModel: feedbackModel)
            logger.error("Fetching profile data failed. Error: \(error) (\(#file):\(#line))")
        }
        await checkInsPromise
        logger.info("Profile data loaded in \(startTime.elapsedTime())ms")
    }

    private func fetchImages() async {
        let (from, to) = getPagination(page: imagePage, size: appModel.rateControl.checkInImagePageSize)
        do {
            let checkIns = try await repository.checkIn.getCheckInImages(by: .profile(profile.id), from: from, to: to)
            checkInImages.append(contentsOf: checkIns)
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Fetching check-in images failed. Description: \(error.localizedDescription). Error: \(error) (\(#file):\(#line))")
        }
    }

    func fetchFeedItems(reset: Bool = false) async {
        guard !isLoading, !isRefreshing else { return }
        if reset {
            isRefreshing = true
        }
        isLoading = true
        do {
            let startTime = DispatchTime.now()
            let lastCheckInId = checkIns.last?.id
            let pageSize = appModel.rateControl.checkInPageSize
            let fetchedCheckIns = try await repository.checkIn.getByProfileId(
                id: profile.id,
                queryType: .paginated(lastCheckInId, pageSize)
            )
            logger.info("Succesfully loaded check-ins after \(lastCheckInId?.rawValue.formatted() ?? "lastest"), page size: \(pageSize) in \(startTime.elapsedTime())ms")
            if reset {
                checkIns = fetchedCheckIns
            } else {
                checkIns.append(contentsOf: fetchedCheckIns)
            }
        } catch {
            guard !error.isCancelled else { return }
            guard !error.isNetworkUnavailable else { return }
            logger.error("Fetching check-ins failed. Error: \(error) (\(#file):\(#line))")
        }
        isLoading = false
        if reset {
            isRefreshing = false
        }
    }
}
