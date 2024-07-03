import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
@Observable
final class CheckInListLoader {
    typealias OnLoadComplete = (_ checkIns: [CheckIn]) async -> Void
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
    var showCheckInsFrom: CheckInSegment {
        didSet {
            onSegmentChange()
        }
    }

    // Dialogs
    var alertError: AlertEvent?
    var errorContentUnavailable: AlertEvent?

    let fetcher: Fetcher
    let id: String
    let pageSize: Int

    init(fetcher: @escaping Fetcher, id: String, pageSize: Int = 10, showCheckInsFrom: CheckInSegment = .everyone) {
        self.fetcher = fetcher
        self.id = id
        self.pageSize = pageSize
        self.showCheckInsFrom = showCheckInsFrom
    }

    func loadData(isRefresh: Bool = false) async {
        if isRefresh {
            logger.info("Refreshing check-in feed data")
            isRefreshing = true
            await fetchFeedItems(reset: true)
            isRefreshing = false
            return
        }
        await fetchFeedItems()
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

    @discardableResult
    func fetchFeedItems(reset: Bool = false) async -> [CheckIn] {
        let (from, to) = getPagination(page: reset ? 0 : page, size: pageSize)
        isLoading = true
        errorContentUnavailable = nil
        switch await fetcher(from, to, showCheckInsFrom) {
        case let .success(fetchedCheckIns):
            logger.info("Succesfully loaded check-ins from \(from) to \(to)")
            withAnimation {
                if reset {
                    checkIns = fetchedCheckIns
                } else {
                    checkIns.append(contentsOf: fetchedCheckIns)
                }
            }
            page += 1
            isLoading = false
            return checkIns
        case let .failure(error):
            guard !error.isCancelled else { return [] }
            logger.error("Fetching check-ins failed. Error: \(error) (\(#file):\(#line))")
            let e = AlertEvent(title: "checkInList.error.failedToLoad.alert")
            if checkIns.isEmpty {
                errorContentUnavailable = e
            }
            guard !error.isNetworkUnavailable else { return [] }
            alertError = e
            isLoading = false
            return []
        }
    }
}
