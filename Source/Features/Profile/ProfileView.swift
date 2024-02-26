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
struct ProfileView: View {
    @Environment(Repository.self) private var repository
    let profile: Profile
    @Binding var scrollToTop: Int
    let isCurrentUser: Bool

    var body: some View {
        ProfileInnerView(repository: repository, profile: profile, scrollToTop: $scrollToTop, isCurrentUser: isCurrentUser)
    }
}

@MainActor
struct ProfileInnerView: View {
    private let logger = Logger(category: "ProfileView")
    @Environment(Repository.self) private var repository
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @State private var alertError: AlertError?
    @State private var refreshId = 0
    @State private var profile: Profile
    @State private var profileSummary: ProfileSummary?
    @State private var checkInImages = [ImageEntity.JoinedCheckIn]()
    @State private var isLoading = false
    @State private var loadImagesTask: Task<Void, Never>?
    @State private var page = 0
    @State private var resultId: Int?
    @Binding var scrollToTop: Int

    private let topAnchor = 0
    private let pageSize = 10
    private let isCurrentUser: Bool
    private let isShownInFull: Bool

    init(repository: Repository, profile: Profile, scrollToTop: Binding<Int>, isCurrentUser: Bool) {
        _profile = State(initialValue: profile)
        _scrollToTop = scrollToTop
        self.isCurrentUser = isCurrentUser
        _checkInLoader = State(initialValue: CheckInListLoader(fetcher: { from, to, _ in
            await repository.checkIn.getByProfileId(id: profile.id, queryType: .paginated(from, to))
        }, id: "ProfileView"))
        isShownInFull = isCurrentUser || !profile.isPrivate
    }

    @State private var checkInLoader: CheckInListLoader

    var showInFull: Bool {
        isShownInFull || friendEnvironmentModel.isFriend(profile)
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                Group {
                    ProfileHeaderAvatarSection(
                        profile: $profile,
                        isCurrentUser: isCurrentUser,
                        showInFull: showInFull,
                        profileSummary: profileSummary
                    )
                    .id(topAnchor)
                    if showInFull {
                        RatingChartView(profile: profile, profileSummary: profileSummary)
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
                }.listRowSeparator(.hidden)

                CheckInListContent(checkIns: $checkInLoader.checkIns, alertError: $checkInLoader.alertError, loadedFrom: .profile(profile), onCheckInUpdate: checkInLoader.onCheckInUpdate, onCreateCheckIn: checkInLoader.onCreateCheckIn, onLoadMore: {
                    checkInLoader.onLoadMore()
                })
                CheckInListLoadingIndicator(isLoading: $checkInLoader.isLoading, isRefreshing: $checkInLoader.isRefreshing)
            }
            .listStyle(.plain)
            .refreshable {
                await getProfileData(isRefresh: true)
            }
            .sensoryFeedback(.success, trigger: friendEnvironmentModel.friends)
            .alertError($alertError)
            .onDisappear {
                loadImagesTask?.cancel()
            }
            .initialTask {
                await getProfileData()
            }
            .initialTask {
                await checkInLoader.loadData()
            }
            .onChange(of: scrollToTop) {
                withAnimation {
                    proxy.scrollTo(topAnchor, anchor: .top)
                }
            }
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

    func getProfileData(isRefresh _: Bool = false) async {
        async let summaryPromise = repository.checkIn.getSummaryByProfileId(id: profile.id)
        async let imagesPromise = repository.checkIn.getCheckInImages(by: .profile(profile), from: 0, to: pageSize)

        let (summaryResult, imagesResult) = await (
            summaryPromise,
            imagesPromise
        )

        switch summaryResult {
        case let .success(summary):
            withAnimation(.easeIn) {
                profileSummary = summary
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Fetching profile data failed. Error: \(error) (\(#file):\(#line))")
        }

        switch imagesResult {
        case let .success(checkIns):
            withAnimation {
                checkInImages.append(contentsOf: checkIns)
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
                checkInImages.append(contentsOf: checkIns)
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
