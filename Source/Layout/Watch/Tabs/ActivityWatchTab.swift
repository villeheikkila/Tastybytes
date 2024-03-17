import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct ActivityWatchTab: View {
    @Environment(Repository.self) private var repository

    var body: some View {
        ActivityWatchTabContent(repository: repository)
    }
}

@MainActor
struct ActivityWatchTabContent: View {
    enum ScreenState {
        case initial, initialized
    }

    private let logger = Logger(category: "ActivityWatchTab")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(ImageUploadEnvironmentModel.self) private var imageUploadEnvironmentModel
    @State private var checkInLoader: CheckInListLoader
    @State private var screenState: ScreenState = .initial

    init(repository: Repository) {
        _checkInLoader = State(initialValue: CheckInListLoader(fetcher: { from, to, _ in
            await repository.checkIn.getActivityFeed(from: from, to: to)
        }, id: "ActivityWatchTab", pageSize: 15))
    }

    var body: some View {
        @Bindable var imageUploadEnvironmentModel = imageUploadEnvironmentModel
        ScrollViewReader { proxy in
            List {
                ForEach(checkInLoader.checkIns) { checkIn in
                    Text(checkIn.product.name)
                        .onAppear {
                            if checkIn == checkInLoader.checkIns.last {
                                checkInLoader.onLoadMore()
                            }
                        }
                }
                CheckInListLoadingIndicator(isLoading: $checkInLoader.isLoading, isRefreshing: $checkInLoader.isRefreshing)
            }
            .listStyle(.plain)
            .refreshable {
                await checkInLoader.fetchFeedItems(reset: true)
            }
            .overlay {
                if checkInLoader.errorContentUnavailable != nil {
                    ContentUnavailableView {
                        Label("activity.error.failedToLoad", systemImage: "exclamationmark.triangle")
                    }
                } else if screenState == .initialized, checkInLoader.checkIns.isEmpty, !checkInLoader.isLoading {
                    EmptyActivityFeedView()
                }
            }
            .task {
                if screenState == .initial {
                    await checkInLoader.loadData()
                    screenState = .initialized
                }
            }
        }
    }
}
