import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ActivityWatchTab: View {
    @Environment(Repository.self) private var repository

    var body: some View {
        ActivityWatchTabContent(repository: repository)
    }
}

struct ActivityWatchTabContent: View {
    private let logger = Logger(category: "ActivityWatchTab")
    @Environment(Repository.self) private var repository
    @Environment(ImageUploadEnvironmentModel.self) private var imageUploadEnvironmentModel
    @State private var checkInLoader: CheckInListLoader
    @State private var state: ScreenState = .loading

    init(repository: Repository) {
        _checkInLoader = State(initialValue: CheckInListLoader(fetcher: { from, to, _ in
            await repository.checkIn.getActivityFeed(query: .paginated(from, to))
        }, id: "ActivityWatchTab", pageSize: 15))
    }

    var body: some View {
        @Bindable var imageUploadEnvironmentModel = imageUploadEnvironmentModel
        List {
            ForEach(checkInLoader.checkIns) { checkIn in
                CheckInWatchListItem(checkIn: checkIn)
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
            } else if state == .populated, checkInLoader.checkIns.isEmpty, !checkInLoader.isLoading {
                EmptyActivityFeedView()
            }
        }
        .task {
            if state == .loading {
                await checkInLoader.loadData()
                state = .populated
            }
        }
    }
}

struct CheckInWatchListItem: View {
    let checkIn: CheckIn

    var fullProductName: String {
        let productName = checkIn.product.formatted(.fullName)
        if let description = checkIn.product.description {
            return "\(productName) \(description)"
        }
        return productName
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .center) {
                Avatar(profile: checkIn.profile)
                    .avatarSize(.medium)
                    .fixedSize()
                Text(checkIn.profile.preferredName)
                    .font(.caption)
                    .foregroundColor(.primary)
                Spacer()
                if let location = checkIn.location {
                    Text(location.formatted(.withEmoji))
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }

            Text(fullProductName)
                .font(.headline)
                .foregroundColor(.primary)

            CheckInImageScrollView(checkIn: checkIn)

            if let rating = checkIn.rating {
                RatingView(rating: rating)
                    .ratingColor(checkIn.isNostalgic ? .purple : .yellow)
            }

            CheckInDateView(checkInAt: checkIn.checkInAt)
        }
    }
}
