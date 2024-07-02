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
    @State private var page = 0
    // Check-ins
    @State private var checkIns = [CheckIn]()

    var body: some View {
        @Bindable var imageUploadEnvironmentModel = imageUploadEnvironmentModel
        ScrollViewReader { proxy in
            List {
                if state == .populated {
                    CheckInListContent(checkIns: $checkIns, loadedFrom: .activity(profileEnvironmentModel.profile), onCheckInUpdate: onCheckInUpdate, onCreateCheckIn: { checkIn in
                        onCreateCheckIn(checkIn)
                        try? await Task.sleep(nanoseconds: 100_000_000)
                        proxy.scrollTo(checkIn.id, anchor: .top)
                    }, onLoadMore: onLoadMore)
                    CheckInListLoadingIndicator(isLoading: $isLoading, isRefreshing: $isRefreshing)
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .refreshable {
                await fetchFeedItems(reset: true)
            }
            .sensoryFeedback(.success, trigger: isRefreshing) { oldValue, newValue in
                oldValue && !newValue
            }
            .overlay {
                if state == .populated {
                    if checkIns.isEmpty, !isLoading {
                        EmptyActivityFeedView()
                    }
                } else {
                    ScreenStateOverlayView(state: state, errorDescription: "") {
                        await fetchFeedItems(reset: true)
                    }
                }
            }
            .toolbar {
                toolbarContent
            }
            .navigationTitle("tab.activity")
            .navigationBarTitleDisplayMode(.inline)
            .initialTask {
                await fetchFeedItems()
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
            RouterLink("settings.navigationTitle", systemImage: "gear", open: .screen(.settings))
                .labelStyle(.iconOnly)
                .imageScale(.large)
        }
    }

    func onCreateCheckIn(_ checkIn: CheckIn) {
        withAnimation {
            checkIns.insert(checkIn, at: 0)
        }
    }

    func onCheckInUpdate(_ checkIn: CheckIn) {
        guard let index = checkIns.firstIndex(where: { $0.id == checkIn.id }) else { return }
        withAnimation {
            checkIns[index] = checkIn
        }
    }

    func onLoadMore() {
        guard loadingCheckInsOnAppearTask == nil else { return }
        loadingCheckInsOnAppearTask = Task {
            defer { loadingCheckInsOnAppearTask = nil }
            logger.info("Loading more items invoked")
            await fetchFeedItems()
        }
    }

    func fetchFeedItems(reset: Bool = false) async {
        if reset {
            isRefreshing = true
        } else {
            isLoading = true
        }
        let (from, to) = getPagination(page: reset ? 0 : page, size: 10)
        switch await repository.checkIn.getActivityFeed(query: .paginated(from, to)) {
        case let .success(fetchedCheckIns):
            guard !Task.isCancelled else { return }
            logger.info("Succesfully loaded check-ins from \(from) to \(to)")
            withAnimation {
                if reset {
                    checkIns = fetchedCheckIns
                } else {
                    checkIns.append(contentsOf: fetchedCheckIns)
                }
                state = .populated
            }
            page += 1
        case let .failure(error):
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
