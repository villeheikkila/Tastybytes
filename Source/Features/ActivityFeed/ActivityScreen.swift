import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ActivityScreen: View {
    private let logger = Logger(category: "CheckInList")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(ImageUploadEnvironmentModel.self) private var imageUploadEnvironmentModel
    @State private var state: ScreenState = .loading

    @State private var loadingCheckInsOnAppearTask: Task<Void, Error>?
    // Feed state
    @State private var isRefreshing = false
    @State private var isLoading = false
    @State private var isInitialLoad = true
    @State private var page = 0
    // Check-ins
    @State private var checkIns = [CheckIn]()

    var body: some View {
        @Bindable var imageUploadEnvironmentModel = imageUploadEnvironmentModel
        ScrollViewReader { proxy in
            List {
                if state == .populated {
                    CheckInListContentView(checkIns: $checkIns, onCheckInUpdate: onCheckInUpdate, onCreateCheckIn: { checkIn in
                        onCreateCheckIn(checkIn)
                        try? await Task.sleep(nanoseconds: 100_000_000)
                        proxy.scrollTo(checkIn.id, anchor: .top)
                    }, onLoadMore: onLoadMore)
                    CheckInListLoadingIndicatorView(isLoading: $isLoading, isRefreshing: $isRefreshing)
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .refreshable {
                await fetchFeedItems(reset: true, onPageLoad: false)
            }
            .checkInCardLoadedFrom(.activity(profileEnvironmentModel.profile))
            .sensoryFeedback(.success, trigger: isRefreshing) { oldValue, newValue in
                oldValue && !newValue
            }
            .overlay {
                if state == .populated {
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
            .task {
                await fetchFeedItems(onPageLoad: true)
            }
            .onChange(of: imageUploadEnvironmentModel.uploadedImageForCheckIn) { _, newValue in
                if let updatedCheckIn = newValue {
                    imageUploadEnvironmentModel.uploadedImageForCheckIn = nil
                    onCheckInUpdate(updatedCheckIn)
                }
            }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            RouterLink("friends.navigationTitle", systemImage: "person.2", open: .screen(.currentUserFriends))
                .labelStyle(.iconOnly)
                .imageScale(.large)
                .customBadge(notificationEnvironmentModel.unreadFriendRequestCount)
        }
        ToolbarItem(placement: .principal) {}
        ToolbarItemGroup(placement: .topBarTrailing) {
            RouterLink("settings.navigationTitle", systemImage: "gear", open: .sheet(.settings))
                .labelStyle(.iconOnly)
                .imageScale(.large)
        }
    }

    private func onCreateCheckIn(_ checkIn: CheckIn) {
        withAnimation {
            checkIns.insert(checkIn, at: 0)
        }
    }

    private func onCheckInUpdate(_ checkIn: CheckIn) {
        guard let index = checkIns.firstIndex(where: { $0.id == checkIn.id }) else { return }
        withAnimation {
            checkIns[index] = checkIn
        }
    }

    private func onLoadMore() {
        guard loadingCheckInsOnAppearTask == nil else { return }
        loadingCheckInsOnAppearTask = Task {
            defer { loadingCheckInsOnAppearTask = nil }
            logger.info("Loading more items invoked")
            await fetchFeedItems()
        }
    }

    private func fetchFeedItems(reset: Bool = false, onPageLoad: Bool = false) async {
        if reset {
            isRefreshing = true
        } else {
            isLoading = true
        }
        let (from, to) = getPagination(page: reset ? 0 : page, size: 10)
        let queryType: ActivityFeedQueryType = if !reset, !isInitialLoad, onPageLoad, let id = checkIns.last?.id {
            .afterId(id)
        } else {
            .paginated(from, to)
        }
        do {
            let fetchedCheckIns = try await repository.checkIn.getActivityFeed(query: queryType)
            guard !Task.isCancelled else { return }
            logger.info("Succesfully loaded check-ins from \(from) to \(to)")
            isInitialLoad = false
            withAnimation {
                if reset {
                    checkIns = fetchedCheckIns
                } else if case .afterId = queryType {
                    checkIns.insert(contentsOf: fetchedCheckIns, at: 0)
                } else {
                    checkIns.append(contentsOf: fetchedCheckIns)
                }
                state = .populated
            }
            page += 1
        } catch {
            guard !error.isCancelled, !Task.isCancelled else { return }
            logger.error("Fetching check-ins failed. Error: \(error) (\(#file):\(#line))")
            if state != .populated {
                state = .error([error])
            }
        }
        if reset {
            isRefreshing = false
        } else {
            isLoading = false
        }
    }
}
