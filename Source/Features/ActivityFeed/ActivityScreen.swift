import Components
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ActivityScreen: View {
    private let logger = Logger(category: "CheckInList")
    @Environment(Repository.self) private var repository
    @Environment(ProfileModel.self) private var profileModel
    @Environment(AppModel.self) private var appModel
    @Environment(NotificationModel.self) private var notificationModel
    @Environment(CheckInUploadModel.self) private var checkInUploadModel
    @State private var state: ScreenState = .loading

    @State private var loadingCheckInsOnAppearTask: Task<Void, Error>?
    // Feed state
    @State private var isRefreshing = false
    @State private var isLoading = false
    @State private var isInitialLoad = true
    @State private var page = 0
    // Check-ins
    @State private var checkIns = [CheckIn.Joined]()

    var body: some View {
        @Bindable var checkInUploadModel = checkInUploadModel
        ScrollViewReader { proxy in
            List {
                if state.isPopulated {
                    CheckInListContentView(checkIns: $checkIns, onCreateCheckIn: { checkIn in
                        checkIns = [checkIn] + checkIns
                        try? await Task.sleep(nanoseconds: 100_000_000)
                        proxy.scrollTo(checkIn.id, anchor: .top)
                    }, onLoadMore: {
                        await fetchFeedItems()
                    })
                    CheckInListLoadingIndicatorView(isLoading: $isLoading, isRefreshing: $isRefreshing)
                }
            }
            .listStyle(.plain)
            .animation(.default, value: checkIns)
            .scrollIndicators(.hidden)
            .refreshable {
                await fetchFeedItems(reset: true, onPageLoad: false)
            }
            .checkInCardLoadedFrom(.activity(profileModel.profile))
            .sensoryFeedback(.success, trigger: isRefreshing) { oldValue, newValue in
                oldValue && !newValue
            }
            .overlay {
                if state.isPopulated {
                    if checkIns.isEmpty, !isLoading {
                        EmptyActivityFeedView()
                    }
                } else {
                    ScreenStateOverlayView(state: state) {
                        await fetchFeedItems(reset: true, onPageLoad: false)
                    }
                }
            }
            .toolbar {
                toolbarContent
            }
            .navigationTitle("tab.activity")
            .navigationBarTitleDisplayMode(.inline)
            .initialTask {
                await fetchFeedItems(onPageLoad: true)
            }
            .onChange(of: checkInUploadModel.uploadedImageForCheckIn) { _, newValue in
                if let updatedCheckIn = newValue {
                    checkInUploadModel.uploadedImageForCheckIn = nil
                    checkIns = checkIns.replacingWithId(updatedCheckIn.id, with: updatedCheckIn)
                }
            }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            RouterLink("friends.navigationTitle", systemImage: "person.2", open: .screen(.currentUserFriends))
                .labelStyle(.iconOnly)
                .imageScale(.large)
                .customBadge(notificationModel.unreadFriendRequestCount)
        }
        ToolbarItem(placement: .principal) {}
        ToolbarItemGroup(placement: .topBarTrailing) {
            RouterLink("settings.navigationTitle", systemImage: "gear", open: .sheet(.settings))
                .labelStyle(.iconOnly)
                .imageScale(.large)
        }
    }

    private func fetchFeedItems(reset: Bool = false, onPageLoad: Bool = false) async {
        if reset {
            isRefreshing = true
        } else {
            isLoading = true
        }
        let (from, to) = getPagination(page: reset ? 0 : page, size: appModel.rateControl.checkInPageSize)
        let queryType: ActivityFeedQueryType = if !reset, !isInitialLoad, onPageLoad, let id = checkIns.first?.id {
            .afterId(id)
        } else {
            .paginated(from, to)
        }
        do {
            let startTime = DispatchTime.now()
            let fetchedCheckIns = try await repository.checkIn.getActivityFeed(query: queryType)
            guard !Task.isCancelled else { return }
            logger.info("Succesfully loaded check-ins from \(from) to \(to)")
            isInitialLoad = false
            if reset {
                checkIns = fetchedCheckIns
            } else if case .afterId = queryType {
                checkIns.insert(contentsOf: fetchedCheckIns, at: 0)
            } else {
                checkIns.append(contentsOf: fetchedCheckIns)
            }
            logger.info("Activity feed data loaded in \(startTime.elapsedTime())ms")
            state = .populated
            page += 1
        } catch {
            guard !error.isCancelled, !Task.isCancelled else { return }
            logger.error("Fetching check-ins failed. Error: \(error) (\(#file):\(#line))")
            if state != .populated {
                state = .error(error)
            }
        }
        if reset {
            isRefreshing = false
        } else {
            isLoading = false
        }
    }
}
