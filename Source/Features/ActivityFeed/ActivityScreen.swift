import Components
import Extensions
import Logging
import Models
import Repositories
import SwiftUI

struct ActivityScreen: View {
    private let logger = Logger(label: "CheckInList")
    @Environment(Repository.self) private var repository
    @Environment(ProfileModel.self) private var profileModel
    @Environment(AppModel.self) private var appModel
    @Environment(CheckInUploadModel.self) private var checkInUploadModel
    @State private var state: ScreenState = .loading
    @State private var checkIns = [CheckIn.Joined]()
    @State private var loadingCheckInsOnAppearTask: Task<Void, Error>?
    @State private var isRefreshing = false
    @State private var isLoading = false

    var body: some View {
        @Bindable var checkInUploadModel = checkInUploadModel
        ScrollViewReader { proxy in
            List {
                if state.isPopulated {
                    CheckInListContentView(checkIns: $checkIns, onCreateCheckIn: { checkIn in
                        checkIns = [checkIn] + checkIns
                        try? await Task.sleep(for: .milliseconds(100))
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
            .checkInLoadedFrom(.activity(profileModel.profile))
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
                .customBadge(profileModel.unreadFriendRequestCount)
        }
        ToolbarItem(placement: .principal) {}
        ToolbarItemGroup(placement: .topBarTrailing) {
            RouterLink("settings.navigationTitle", systemImage: "gear", open: .sheet(.settings))
                .labelStyle(.iconOnly)
                .imageScale(.large)
        }
    }

    private func fetchFeedItems(reset: Bool = false, onPageLoad _: Bool = false) async {
        if reset {
            isRefreshing = true
        } else {
            isLoading = true
        }
        let lastCheckInId = reset ? nil : checkIns.last?.id
        let pageSize = appModel.rateControl.checkInPageSize
        let startTime = DispatchTime.now()

        do {
            let fetchedCheckIns = try await repository.checkIn.getActivityFeed(id: lastCheckInId, pageSize: pageSize)
            guard !Task.isCancelled else { return }
            if reset {
                checkIns = fetchedCheckIns
            } else {
                checkIns.append(contentsOf: fetchedCheckIns)
            }
            state = .populated
            let queryDescription = if let lastCheckInId {
                "check-ins from cursor \(lastCheckInId.rawValue)"
            } else {
                "latest check-ins"
            }
            logger.info("Succesfully loaded \(queryDescription), page size: \(pageSize) in \(startTime.elapsedTime())ms. Current feed length: \(checkIns.count)")
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
