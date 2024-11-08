import Components
import Extensions
import Logging
import Models
import Repositories
import SwiftUI

struct ActivityScreen: View {
    private let logger = Logger(label: "CheckInList")
    @Environment(ProfileModel.self) private var profileModel
    @Environment(CheckInModel.self) private var checkInModel

    var body: some View {
        @Bindable var checkInModel = checkInModel
        ScrollViewReader { proxy in
            List {
                CheckInListContentView(checkIns: $checkInModel.checkIns, onCreateCheckIn: { checkIn in
                    checkInModel.addNewCheckIn(checkIn)
                    try? await Task.sleep(for: .milliseconds(100))
                    proxy.scrollTo(checkIn.id, anchor: .top)
                }, onLoadMore: {
                    await checkInModel.fetchFeedItems(mode: .loadMore)
                })
                ActivityLoadingIndicatorView(state: checkInModel.state) {
                    await checkInModel.fetchFeedItems(mode: .loadMore)
                }
            }
            .listStyle(.plain)
            .animation(.easeIn, value: checkInModel.checkIns)
            .scrollIndicators(.hidden)
            .refreshable {
                await checkInModel.fetchFeedItems(mode: .reset)
            }
            .checkInLoadedFrom(.activity(profileModel.profile))
            .overlay {
                switch checkInModel.state {
                case let .error(error):
                    ScreenContentUnavailableView(error: error, description: nil) {
                        await checkInModel.fetchFeedItems(mode: .reset)
                    }
                case .loading:
                    ScreenLoadingView()
                case .populated where checkInModel.checkIns.isEmpty:
                    EmptyActivityFeedView()
                default:
                    EmptyView()
                }
            }
            .toolbar {
                toolbarContent
            }
            .navigationTitle("tab.activity")
            .navigationBarTitleDisplayMode(.inline)
            .initialTask {
                await checkInModel.fetchFeedItems(mode: .pageLoad)
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
}

struct ActivityLoadingIndicatorView: View {
    let state: ActivityState
    var onRetry: (() async -> Void)? = nil

    var body: some View {
        Group {
            switch state {
            case .loadingMore:
                ProgressView()
                    .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)

            case .errorLoadingMore:
                VStack(spacing: 8) {
                    Text("Failed to load more items")
                        .foregroundStyle(.secondary)
                    AsyncButton("Retry", systemImage: "arrow.clockwise") {
                        await onRetry?()
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)

            default:
                EmptyView()
            }
        }
        .listRowSeparator(.hidden)
    }
}

@MainActor
@Observable
class CheckInModel {
    private let logger = Logger(label: "CheckInModel")
    // state
    var state: ActivityState = .loading
    var checkIns = [CheckIn.Joined]()
    // depedencies
    private let repository: Repository
    private let onSnack: OnSnack
    // options
    private let pageSize: Int
    // task management
    private var currentFetchTask: Task<Void, Never>?

    init(
        repository: Repository,
        onSnack: @escaping OnSnack,
        pageSize: Int
    ) {
        self.repository = repository
        self.onSnack = onSnack
        self.pageSize = pageSize
    }

    enum FetchFeedMode {
        case pageLoad
        case reset
        case loadMore
    }

    func fetchFeedItems(mode: FetchFeedMode) async {
        guard mode == .reset || currentFetchTask == nil else { return }
        currentFetchTask?.cancel()
        currentFetchTask = nil
        let task = Task {
            state = switch mode {
            case .pageLoad: .loading
            case .reset: .refreshing
            case .loadMore: .loadingMore
            }
            let lastCheckInId = mode == .reset ? nil : checkIns.last?.id
            let startTime = DispatchTime.now()
            do {
                let fetchedCheckIns = try await repository.checkIn.getActivityFeed(
                    id: lastCheckInId,
                    pageSize: pageSize
                )
                guard !Task.isCancelled else { return }
                checkIns = mode == .reset ? fetchedCheckIns : checkIns + fetchedCheckIns
                logger.info("Successfully loaded check-ins\(lastCheckInId.map { " from cursor \($0.rawValue)" } ?? ""), page size: \(pageSize) in \(startTime.elapsedTime())ms. Current feed length: \(checkIns.count)")
            } catch {
                guard !error.isCancelled else { return }
                logger.error("Fetching check-ins failed. Error: \(error) (\(#file):\(#line))")
                state = switch state {
                case .loading, .refreshing, .error:
                    .error(error)
                case .loadingMore, .errorLoadingMore:
                    .errorLoadingMore(error)
                case .populated:
                    checkIns.isEmpty ? .error(error) : .errorLoadingMore(error)
                }
            }
        }
        currentFetchTask = task
        await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            task.cancel()
        }
        currentFetchTask = nil
    }

    func addNewCheckIn(_ checkIn: CheckIn.Joined) {
        checkIns = [checkIn] + checkIns
    }

    var uploadedImageForCheckIn: CheckIn.Joined?

    public func uploadCheckInImage(checkIn: CheckIn.Joined, images: [UIImage]) {
        Task(priority: .userInitiated) {
            var uploadedImages = [ImageEntity.Saved]()
            for image in images {
                let blurHash: String? = if let hash = image.resize(to: 100)?.blurHash(numberOfComponents: (5, 5)) {
                    BlurHash(hash: hash, height: image.size.height, width: image.size.width).encoded
                } else {
                    nil
                }
                guard let data = image.jpegData(compressionQuality: 0.7) else { return }
                do {
                    let imageEntity = try await repository.checkIn.uploadImage(id: checkIn.id, data: data, userId: checkIn.profile.id, blurHash: blurHash)
                    uploadedImages.append(imageEntity)
                } catch {
                    guard !error.isCancelled else { return }
                    onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Failed to add category")))
                    logger.error("Failed to upload image to check-in '\(checkIn.id)'. Error: \(error) (\(#file):\(#line))")
                }
            }
            let uploadedImageForCheckIn = checkIn.copyWith(images: checkIn.images + uploadedImages)
            checkIns = checkIns.replacingWithId(checkIn.id, with: uploadedImageForCheckIn)
            self.uploadedImageForCheckIn = uploadedImageForCheckIn
        }
    }
}

public enum ActivityState: Equatable {
    case loading
    case loadingMore
    case refreshing
    case populated
    case error(Error)
    case errorLoadingMore(Error)

    public static func == (lhs: ActivityState, rhs: ActivityState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.populated, .populated), (.refreshing, .refreshing):
            true
        case let (.error(lhsErrors), .error(rhsErrors)), let (.errorLoadingMore(lhsErrors), .errorLoadingMore(rhsErrors)):
            lhsErrors.localizedDescription == rhsErrors.localizedDescription
        default:
            false
        }
    }
}
