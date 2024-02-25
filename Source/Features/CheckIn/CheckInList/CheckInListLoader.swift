import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
@Observable
final class CheckInListLoader {
    typealias Fetcher = (_ from: Int, _ to: Int) async -> Result<[CheckIn], Error>
    private let logger = Logger(category: "CheckInLoader")

    var loadingCheckInsOnAppear: Task<Void, Error>?
    // Feed state
    var refreshId = 0
    var resultId: Int?
    var isRefreshing = false
    var isLoading = false
    var page = 0
    // Check-ins
    var checkIns = [CheckIn]()
    var showCheckInsFrom: CheckInSegment = .everyone
    var currentShowCheckInsFrom: CheckInSegment = .everyone
    // Dialogs
    var alertError: AlertError?
    var errorContentUnavailable: AlertError?

    let fetcher: Fetcher
    let id: String

    init(fetcher: @escaping Fetcher, id: String) {
        self.fetcher = fetcher
        self.id = id
    }

    private let pageSize = 10

    func loadData(refreshId: Int) async {
        let id = id
        guard refreshId != resultId else {
            logger.info("Already loaded data for \(id) with id: \(self.refreshId)")
            return
        }
        if refreshId == 0 {
            logger.info("Loading initial check-in feed data for \(id)")
            await fetchFeedItems(onComplete: { _ in
                self.logger.info("Loading initial check-ins completed for \(self.id)")
            })
            resultId = refreshId
            return
        }
        logger.info("Refreshing check-in feed data for \(id) with id: \(self.refreshId)")
        isRefreshing = true
        async let feedItemsPromise: Void = fetchFeedItems(
            reset: true,
            onComplete: { _ in
                self.logger.info("Refreshing check-ins completed for \(self.id) with id: \(self.refreshId)")
            }
        )
        _ = await (feedItemsPromise)
        isRefreshing = false
        resultId = refreshId
    }

    func onCheckInUpdate(_ checkIn: CheckIn) {
        guard let index = checkIns.firstIndex(where: { $0.id == checkIn.id }) else { return }
        checkIns[index] = checkIn
    }

    func onLoadMore() {
        guard loadingCheckInsOnAppear == nil else { return }
        loadingCheckInsOnAppear = Task {
            defer { loadingCheckInsOnAppear = nil }
            logger.info("Loading more items invoked")
            await fetchFeedItems()
        }
    }

    func fetchFeedItems(
        reset: Bool = false,
        onComplete: (@MainActor @Sendable (_ checkIns: [CheckIn]) async -> Void)? = nil
    ) async {
        let (from, to) = getPagination(page: reset ? 0 : page, size: pageSize)
        isLoading = true
        errorContentUnavailable = nil
        switch await fetcher(from, to) {
        case let .success(fetchedCheckIns):
            withAnimation {
                if reset {
                    checkIns = fetchedCheckIns
                } else {
                    checkIns.append(contentsOf: fetchedCheckIns)
                }
            }
            page += 1
            if let onComplete {
                await onComplete(checkIns)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            let e = AlertError(title: "checkInList.error.failedToLoad.alert")
            if checkIns.isEmpty {
                errorContentUnavailable = e
            } else {
                alertError = e
            }
            logger.error("Fetching check-ins failed. Error: \(error) (\(#file):\(#line))")
        }
        isLoading = false
    }
}
