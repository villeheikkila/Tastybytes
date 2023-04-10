import SwiftUI

extension CheckInListView {
  enum Fetcher {
    case activityFeed
    case product(Product.Joined)
    case profile(Profile)
    case location(Location)
  }

  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "CheckInListView")
    let client: Client
    @Published var showDeleteConfirmationFor: CheckIn? {
      didSet {
        showDeleteCheckInConfirmationDialog = true
      }
    }

    @Published var showDeleteCheckInConfirmationDialog = false
    @Published var editCheckIn: CheckIn?
    @Published var checkIns = [CheckIn]()
    @Published var isLoading = false
    private let pageSize = 10
    private var page = 0

    let fetcher: Fetcher

    var uniqueCheckIns: [CheckIn] {
      checkIns.unique(selector: { $0.id == $1.id })
    }

    init(_ client: Client, fetcher: Fetcher) {
      self.fetcher = fetcher
      self.client = client
    }

    func refresh() async {
      page = 0
      checkIns = [CheckIn]()
      await fetchActivityFeedItems()
    }

    func getPagination(page: Int, size: Int) -> (Int, Int) {
      let limit = size + 1
      let from = page * limit
      let to = from + size
      return (from, to)
    }

    func deleteCheckIn(checkIn: CheckIn) {
      Task {
        switch await client.checkIn.delete(id: checkIn.id) {
        case .success:
          withAnimation {
            checkIns.remove(object: checkIn)
          }
        case let .failure(error):
          logger.error("deleting check-in \(checkIn.id) failed: \(error.localizedDescription)")
        }
      }
    }

    func onCheckInUpdate(_ checkIn: CheckIn) {
      guard let index = checkIns.firstIndex(where: { $0.id == checkIn.id }) else { return }
      checkIns[index] = checkIn
    }

    func fetchActivityFeedItems(onComplete: (() -> Void)? = nil) async {
      let (from, to) = getPagination(page: page, size: pageSize)
      isLoading = true

      switch await checkInFetcher(from: from, to: to) {
      case let .success(checkIns):
        withAnimation {
          self.checkIns.append(contentsOf: checkIns)
        }
        page += 1
        isLoading = false

        if let onComplete {
          onComplete()
        }
      case let .failure(error):
        logger.error("fetching check-ins failed: \(error.localizedDescription)")
      }
    }

    func checkInFetcher(from: Int, to: Int) async -> Result<[CheckIn], Error> {
      switch fetcher {
      case .activityFeed:
        return await client.checkIn.getActivityFeed(from: from, to: to)
      case let .profile(product):
        return await client.checkIn.getByProfileId(id: product.id, queryType: .paginated(from, to))
      case let .product(product):
        return await client.checkIn.getByProductId(id: product.id, from: from, to: to)
      case let .location(location):
        return await client.checkIn.getByLocation(locationId: location.id, from: from, to: to)
      }
    }
  }
}
