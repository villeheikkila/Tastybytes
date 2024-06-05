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
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @State private var checkInLoader: CheckInListLoader
    @State private var alertError: AlertError?
    @State private var profile: Profile
    @State private var profileSummary: ProfileSummary?
    @State private var checkInImages = [ImageEntity.JoinedCheckIn]()
    @State private var isLoading = false
    @State private var loadImagesTask: Task<Void, Never>?
    @State private var page = 0
    @State private var showPicker = false
    @State private var selectedItem: PhotosPickerItem?
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

    var showInFull: Bool {
        isShownInFull || friendEnvironmentModel.isFriend(profile)
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
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
                        CheckInImagesSection(checkInImages: checkInImages, isLoading: isLoading, onLoadMore: {
                            loadImagesTask = Task {
                                await fetchImages()
                            }
                        })
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
            .photosPicker(isPresented: $showPicker, selection: $selectedItem, matching: .images, photoLibrary: .shared())
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
            .onChange(of: scrollToTop) {
                withAnimation {
                    proxy.scrollTo(topAnchor, anchor: .top)
                }
            }
            .onChange(of: selectedItem) { _, newValue in
                Task {
                    guard let data = await newValue?.getJPEG() else { return }
                    await uploadAvatar(userId: profileEnvironmentModel.id, data: data)
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

    func getProfileData(isRefresh: Bool = false) async {
        async let productPromise: Void = checkInLoader.loadData(isRefresh: isRefresh)
        async let summaryPromise = repository.checkIn.getSummaryByProfileId(id: profile.id)
        async let imagesPromise = repository.checkIn.getCheckInImages(by: .profile(profile), from: 0, to: pageSize)
        let (summaryResult, imagesResult) = await (summaryPromise, imagesPromise)

        switch summaryResult {
        case let .success(summary):
            withAnimation {
                profileSummary = summary
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Fetching profile data failed. Error: \(error) (\(#file):\(#line))")
        }

        switch imagesResult {
        case let .success(images):
            withAnimation {
                if isRefresh {
                    checkInImages = images
                } else {
                    checkInImages.append(contentsOf: images)
                }
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

        await productPromise
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
    
    func uploadAvatar(userId: UUID, data: Data) async {
        switch await repository.profile.uploadAvatar(userId: userId, data: data) {
        case let .success(imageEntity):
            profile = profile.copyWith(avatars: [imageEntity])
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Uploading of a avatar for \(userId) failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
