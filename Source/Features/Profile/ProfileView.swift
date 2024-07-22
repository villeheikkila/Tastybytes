import Charts
import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import PhotosUI
import Repositories
import SwiftUI

struct ProfileView: View {
    @Environment(Repository.self) private var repository
    let profile: Profile
    let isCurrentUser: Bool

    var body: some View {
        ProfileInnerView(repository: repository, profile: profile, isCurrentUser: isCurrentUser)
    }
}

struct ProfileInnerView: View {
    private let logger = Logger(category: "ProfileView")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var checkInLoader: CheckInListLoader
    @State private var profile: Profile
    @State private var profileSummary: ProfileSummary?
    @State private var checkInImages = [ImageEntity.JoinedCheckIn]()
    @State private var isLoading = false
    @State private var isLoadingImages = false
    @State private var loadImagesTask: Task<Void, Never>?
    @State private var page = 0
    @State private var imagePage = 0
    @State private var showPicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var state: ScreenState = .loading

    private let topAnchor = 0
    private let pageSize = 10
    private let isCurrentUser: Bool
    private let isShownInFull: Bool

    init(repository: Repository, profile: Profile, isCurrentUser: Bool) {
        _profile = State(initialValue: profile)
        self.isCurrentUser = isCurrentUser
        _checkInLoader = State(initialValue: CheckInListLoader(fetcher: { from, to, _ in
            try await repository.checkIn.getByProfileId(id: profile.id, queryType: .paginated(from, to))
        }, id: "ProfileView"))
        isShownInFull = isCurrentUser || !profile.isPrivate
    }

    private var showInFull: Bool {
        isShownInFull || friendEnvironmentModel.isFriend(profile)
    }

    var body: some View {
        List {
            if state.isPopulated {
                content
            }
        }
        .listStyle(.plain)
        .refreshable {
            await getProfileData(isRefresh: true)
        }
        .checkInCardLoadedFrom(.profile(profile))
        .overlay {
            ScreenStateOverlayView(state: state) {
                await getProfileData(isRefresh: true)
            }
        }
        .photosPicker(isPresented: $showPicker, selection: $selectedItem, matching: .images, photoLibrary: .shared())
        .sensoryFeedback(.success, trigger: friendEnvironmentModel.friends)
        .onDisappear {
            loadImagesTask?.cancel()
        }
        .initialTask {
            await getProfileData()
        }
        .task(id: selectedItem) {
            guard let data = await selectedItem?.getJPEG() else { return }
            await profileEnvironmentModel.uploadAvatar(data: data)
            withAnimation {
                profile = profileEnvironmentModel.profile
            }
        }
    }

    @ViewBuilder private var content: some View {
        Group {
            ProfileHeaderAvatarSection(
                showPicker: $showPicker, profile: $profile,
                isCurrentUser: isCurrentUser,
                showInFull: showInFull,
                profileSummary: profileSummary
            )
            .id(topAnchor)
            if showInFull {
                RatingChartView(profile: profile, profileSummary: profileSummary)
                if !checkInImages.isEmpty {
                    CheckInImagesSection(checkInImages: checkInImages, isLoading: isLoadingImages, onLoadMore: {
                        guard loadImagesTask == nil else { return }
                        loadImagesTask = Task {
                            await fetchImages()
                        }
                    })
                }
                ProfileSummarySection(profile: profile, profileSummary: profileSummary)
                ProfileJoinedAtSection(joinedAt: profile.joinedAt)
                sendFriendRequestSection
                ProfileLinksSection(profile: profile, isCurrentUser: isCurrentUser)
            } else {
                PrivateProfileSign()
                sendFriendRequestSection
            }
        }.listRowSeparator(.hidden)

        CheckInListContentView(checkIns: $checkInLoader.checkIns, onCheckInUpdate: checkInLoader.onCheckInUpdate, onCreateCheckIn: checkInLoader.onCreateCheckIn, onLoadMore: {
            checkInLoader.onLoadMore()
        })
        CheckInListLoadingIndicatorView(isLoading: $checkInLoader.isLoading, isRefreshing: $checkInLoader.isRefreshing)
    }

    @ViewBuilder private var sendFriendRequestSection: some View {
        if !isCurrentUser, friendEnvironmentModel.hasNoFriendStatus(friend: profile) || (friendEnvironmentModel.isPendingCurrentUserApproval(profile) != nil) {
            ProfileFriendActionSection(profile: profile)
        }
    }

    private func getProfileData(isRefresh: Bool = false) async {
        async let productPromise: Void = checkInLoader.loadData(isRefresh: isRefresh)
        async let summaryPromise = repository.checkIn.getSummaryByProfileId(id: profile.id)
        async let imagesPromise = repository.checkIn.getCheckInImages(by: .profile(profile), from: 0, to: pageSize)
        var errors = [Error]()
        do {
            let (summaryResult, imagesResult) = try await (summaryPromise, imagesPromise)
            withAnimation {
                profileSummary = summaryResult
            }
            withAnimation {
                imagePage = 1
                checkInImages = imagesResult
            }
            page += 1
            isLoading = false
        } catch {
            errors.append(error)
            logger.error("Fetching profile data failed. Error: \(error) (\(#file):\(#line))")
        }
        if state != .populated {
            state = .getState(errors: errors, withHaptics: isRefresh, feedbackEnvironmentModel: feedbackEnvironmentModel)
        }
        await productPromise
    }

    private func fetchImages() async {
        defer { loadImagesTask = nil }
        let (from, to) = getPagination(page: imagePage, size: pageSize)
        isLoadingImages = true

        do {
            let checkIns = try await repository.checkIn.getCheckInImages(by: .profile(profile), from: from, to: to)
            withAnimation {
                checkInImages.append(contentsOf: checkIns)
            }
            imagePage += 1
            isLoadingImages = false
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Fetching check-in images failed. Description: \(error.localizedDescription). Error: \(error) (\(#file):\(#line))")
        }
    }
}
