//
//  ContentView.swift
//  tastey.watchkitapp Watch App
//
//  Created by Ville Heikkilä on 22.8.2023.
//

import Models
import OSLog
import Repositories
import Supabase
import SwiftUI

enum Route: CaseIterable, Identifiable {
    var id: String {
        switch self {
        case .activity:
            "Activity"
        case .profile:
            "Profile"
        case .search:
            "Search"
        }
    }

    var title: String {
        switch self {
        case .activity:
            "activity"
        case .profile:
            "profile"
        case .search:
            "search"
        }
    }

    case activity
    case search
    case profile
}

struct ContentView: View {
    let supabaseClient: SupabaseClient
    @State private var repository: Repository

    init(supabaseClient: SupabaseClient) {
        let repository = Repository(supabaseClient: supabaseClient)
        self.supabaseClient = supabaseClient
        _repository = State(wrappedValue: repository)
    }

    @State var selected: Route? = .activity

    var body: some View {
        ActivityFeed()
            .environment(repository)
            .task {
                await supabaseClient.auth.initialize()
            }
    }
}

struct ActivityFeed: View {
    enum Fetcher {
        case activityFeed
        case product(Product.Joined)
        case profile(Profile)
        case location(Location)

        @ViewBuilder
        var emptyContentView: some View {
            switch self {
            case .activityFeed:
                EmptyView()
            default:
                EmptyView()
            }
        }

        var showCheckInSegmentationPicker: Bool {
            switch self {
            case .location, .product:
                true
            default:
                false
            }
        }
    }

    let logger = Logger(category: "ActivityFeed")
    @Environment(Repository.self) private var repository
    @State private var isLoading = false
    @State private var initialLoadCompleted = false
    @State private var page = 0
    @State private var showCheckInsFrom: CheckInSegment = .everyone
    @State private var checkIns = [CheckIn]()
    private let pageSize = 5
    private let fetcher: Fetcher = .activityFeed

    var body: some View {
        List {
            Text("hei")
            ForEach(checkIns) { checkIn in
                Text(checkIn.product.name)
            }
        }.task {
            await fetchFeedItems()
        }
    }

    func fetchFeedItems(onComplete: ((_ checkIns: [CheckIn]) async -> Void)? = nil) async {
        let (from, to) = getPagination(page: page, size: pageSize)
        print("hei")

        isLoading = true

        switch await checkInFetcher(from: from, to: to) {
        case let .success(checkIns):
            await MainActor.run {
                withAnimation {
                    self.checkIns.append(contentsOf: checkIns)
                }
            }
            page += 1
            isLoading = false

            if let onComplete {
                await onComplete(checkIns)
            }
        case let .failure(error):
            print(error.localizedDescription)
            guard !error.localizedDescription.contains("cancelled") else { return }
            logger.error("Fetching check-ins failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func checkInFetcher(from: Int, to: Int) async -> Result<[CheckIn], Error> {
        switch fetcher {
        case .activityFeed:
            await repository.checkIn.getActivityFeed(from: from, to: to)
        case let .profile(product):
            await repository.checkIn.getByProfileId(id: product.id, queryType: .paginated(from, to))
        case let .product(product):
            await repository.checkIn.getByProductId(
                id: product.id,
                segment: showCheckInsFrom,
                from: from,
                to: to
            )
        case let .location(location):
            await repository.checkIn.getByLocation(
                locationId: location.id,
                segment: showCheckInsFrom,
                from: from,
                to: to
            )
        }
    }

    func getPagination(page: Int, size: Int) -> (Int, Int) {
        let limit = size + 1
        let from = page * limit
        let to = from + size
        return (from, to)
    }
}
