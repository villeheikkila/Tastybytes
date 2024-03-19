import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
@Observable
final class CheckInListLoader {
    typealias OnLoadComplete = @MainActor @Sendable (_ checkIns: [CheckIn]) async -> Void
    typealias Fetcher = (_ from: Int, _ to: Int, _ segment: CheckInSegment) async -> Result<[CheckIn], Error>
    private let logger = Logger(category: "CheckInLoader")

    var loadingCheckInsOnAppearTask: Task<Void, Error>?
    var onSegmentChangeTask: Task<Void, Error>?
    // Feed state
    var isRefreshing = false
    var isLoading = false
    var page = 0
    // Check-ins
    var checkIns = [CheckIn]()
    var showCheckInsFrom: CheckInSegment = .everyone {
        didSet {
            onSegmentChange()
        }
    }

    // Dialogs
    var alertError: AlertError?
    var errorContentUnavailable: AlertError?

    let fetcher: Fetcher
    let id: String
    let pageSize: Int

    init(fetcher: @escaping Fetcher, id: String, pageSize: Int = 10) {
        self.fetcher = fetcher
        self.id = id
        self.pageSize = pageSize
    }

    func loadData(isRefresh: Bool = false, onComplete: OnLoadComplete? = nil) async {
        if isRefresh {
            logger.info("Refreshing check-in feed data")
            isRefreshing = true
            await fetchFeedItems(
                reset: true,
                onComplete: onComplete
            )
            isRefreshing = false
            return
        }
        await fetchFeedItems(
            onComplete: { _ in
                self.logger.info("Refreshing check-ins completed for \(self.id)")
            }
        )
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

    func onUpdateProduct(_ product: Product.Joined) {
        checkIns = checkIns.map { checkIn in
            if checkIn.product.id == product.id {
                checkIn.copyWith(product: product)
            } else {
                checkIn
            }
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

    func onSegmentChange() {
        onSegmentChangeTask?.cancel()
        loadingCheckInsOnAppearTask?.cancel()
        onSegmentChangeTask = Task {
            await loadData(isRefresh: true)
        }
    }

    func fetchFeedItems(
        reset: Bool = false,
        onComplete: OnLoadComplete? = nil
    ) async {
        let (from, to) = getPagination(page: reset ? 0 : page, size: pageSize)
        isLoading = true
        errorContentUnavailable = nil
        switch await fetcher(from, to, showCheckInsFrom) {
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
            logger.error("Fetching check-ins failed. Error: \(error) (\(#file):\(#line))")
            let e = AlertError(title: "checkInList.error.failedToLoad.alert")
            if checkIns.isEmpty {
                errorContentUnavailable = e
            }
            guard !error.isNetworkUnavailable else { return }
            alertError = e
        }
        isLoading = false
    }
}
