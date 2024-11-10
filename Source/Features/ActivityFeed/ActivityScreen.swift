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
                ForEach(checkInModel.checkIns) { checkIn in
                    CheckInListCardView(
                        checkIn: checkIn,
                        onUpdate: checkInModel.onUpdateCheckIn,
                        onDelete: checkInModel.onDeleteCheckIn,
                        onCreate: { item in await checkInModel.onCreateCheckIn(item, scrollProxy: proxy) }
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .id(checkIn.id)
                    .onAppear {
                        checkInModel.onNewActiveItem(checkIn)
                    }
                }
                ActivityLoadingIndicatorView(state: checkInModel.state) {
                    await checkInModel.fetchFeedItems(mode: .retry)
                }
            }
            .listStyle(.plain)
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
            .animation(.easeIn, value: checkInModel.checkIns)
            .initialTask {
                await checkInModel.fetchFeedItems(mode: .pageLoad)
            }
            .task {
                await checkInModel.listenToCheckInImageUploads()
            }
            .onChange(of: checkInModel.state) { _, newValue in
                print("CheckInModel changed: \(newValue)")
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

enum ActivityFeedMode: Equatable {
    case all
    case currentUser
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
    private let loadMoreThreshold: Int
    // task management
    private var currentFetchTask: Task<Void, Never>?
    let uploadQueue: UploadQueue

    init(
        repository: Repository,
        onSnack: @escaping OnSnack,
        storeAt: URL,
        pageSize: Int,
        loadMoreThreshold: Int
    ) {
        self.repository = repository
        self.onSnack = onSnack
        self.pageSize = pageSize
        self.loadMoreThreshold = loadMoreThreshold
        uploadQueue = UploadQueue(storeAt: storeAt,
                                  uploadImage: { checkInId, imageData, userId, blurHash in try await repository.checkIn.uploadImage(id: checkInId, data: imageData, userId: userId, blurHash: blurHash) })
    }

    enum FetchFeedMode: Equatable {
        case pageLoad
        case reset
        case loadMore(CheckIn.Id)
        case retry
    }

    func onNewActiveItem(_ item: CheckIn.Joined) {
        let numberOfCheckIns = checkIns.count
        let index = checkIns.firstIndex { $0.id == item.id }
        guard let index, index + loadMoreThreshold > numberOfCheckIns else { return }
        Task {
            await fetchFeedItems(mode: .loadMore(item.id))
        }
    }

    func onCreateCheckIn(_ item: CheckIn.Joined, scrollProxy: ScrollViewProxy) async {
        checkIns = [item] + checkIns
        try? await Task.sleep(for: .milliseconds(100))
        scrollProxy.scrollTo(item.id, anchor: .top)
    }

    func onUpdateCheckIn(_ item: CheckIn.Joined) async {
        checkIns = checkIns.replacingWithId(item.id, with: item)
    }

    func onDeleteCheckIn(_ item: CheckIn.Joined) async {
        do {
            try await repository.checkIn.delete(id: item.id)
            checkIns.remove(object: item)
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Deleting check-in failed. Error: \(error) (\(#file):\(#line))")
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle", message: "checkIn.delete.failure.alert")))
        }
    }

    func fetchFeedItems(mode: FetchFeedMode) async {
        guard mode == .reset || currentFetchTask == nil else { return }
        currentFetchTask?.cancel()
        currentFetchTask = nil
        let task = Task {
            state = switch mode {
            case .pageLoad where checkIns.isEmpty: .loading
            case .reset: .refreshing
            case .loadMore, .pageLoad, .retry: .loadingMore
            }
            let startTime = DispatchTime.now()
            do {
                let cursor = mode == .reset ? nil : checkIns.last?.id
                let fetchedCheckIns = try await repository.checkIn.getActivityFeed(
                    id: cursor,
                    pageSize: pageSize,
                    filter: .both
                )
                guard !Task.isCancelled else { return }
                withAnimation(.easeIn) {
                    state = .populated
                }
                checkIns = mode == .reset ? fetchedCheckIns : checkIns + fetchedCheckIns
                logger.info("Successfully loaded check-ins\(cursor.map { " from cursor \($0.rawValue)" } ?? ""), page size: \(pageSize) in \(startTime.elapsedTime())ms. Current feed length: \(checkIns.count)")
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

    public func uploadCheckInImage(checkIn: CheckIn.Joined, images: [UIImage]) {
        Task {
            for image in images {
                guard let data = image.jpegData(compressionQuality: 0.7) else { continue }
                let blurHash: String? = if let hash = image.resize(to: 32)?.blurHash(numberOfComponents: (8, 6)) {
                    BlurHash(hash: hash, height: image.size.height, width: image.size.width).encoded
                } else {
                    nil
                }
                await uploadQueue.enqueue(checkIn, imageData: data, blurHash: blurHash)
            }
        }
    }

    public func listenToCheckInImageUploads() async {
        for await (checkInId, image) in await uploadQueue.uploads {
            if let index = checkIns.firstIndex(where: { $0.id == checkInId }) {
                let updatedCheckIn = checkIns[index].copyWith(images: checkIns[index].images + [image])
                checkIns[index] = updatedCheckIn
            }
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

actor UploadQueue {
    private let logger = Logger(label: "UploadQueue")

    typealias OnCompletedUpload = @Sendable (CheckIn.Id, ImageEntity.Saved) -> Void
    typealias OnUploadImage = @Sendable (
        _ id: CheckIn.Id,
        _ data: Data,
        _ userId: Profile.Id,
        _ blurHash: String?
    ) async throws -> ImageEntity.Saved

    private struct PendingUpload: Codable {
        let checkInId: CheckIn.Id
        let imageData: Data
        let userId: Profile.Id
        let createdAt: Date
        let blurHash: String?
    }

    private let fileManager = FileManager.default
    private let queueDirectory: URL
    private var currentTask: Task<Void, Never>?
    private let uploadImage: OnUploadImage

    init(storeAt: URL, uploadImage: @escaping OnUploadImage) {
        var continuation: AsyncStream<(CheckIn.Id, ImageEntity.Saved)>.Continuation!
        uploadStream = AsyncStream { c in
            continuation = c
        }
        self.continuation = continuation
        self.uploadImage = uploadImage
        queueDirectory = storeAt.appendingPathComponent("ImageUploadQueue", isDirectory: true)
        try? fileManager.createDirectory(at: queueDirectory, withIntermediateDirectories: true)
    }

    private func loadPendingUploads() throws -> [PendingUpload] {
        let files = try fileManager.contentsOfDirectory(
            at: queueDirectory,
            includingPropertiesForKeys: [.creationDateKey],
            options: []
        )
        return try files
            .filter { file in file.pathExtension == "upload" }
            .map { file in try JSONDecoder().decode(PendingUpload.self, from: Data(contentsOf: file)) }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func enqueue(_ checkIn: CheckIn.Joined, imageData: Data, blurHash: String?) async {
        let pendingUpload = PendingUpload(
            checkInId: checkIn.id,
            imageData: imageData,
            userId: checkIn.profile.id,
            createdAt: Date(),
            blurHash: blurHash
        )
        try? await save(pendingUpload)
        await processQueue()
    }

    private func save(_ upload: PendingUpload) async throws {
        let fileName = "\(upload.createdAt.timeIntervalSince1970)_\(UUID().uuidString).upload"
        let fileURL = queueDirectory.appendingPathComponent(fileName)
        let data = try JSONEncoder().encode(upload)
        try data.write(to: fileURL)
    }

    private func removeUploadFile(createdAt: Date) {
        let files = (try? fileManager.contentsOfDirectory(at: queueDirectory, includingPropertiesForKeys: nil)) ?? []
        for file in files where file.lastPathComponent.starts(with: "\(createdAt.timeIntervalSince1970)") {
            try? fileManager.removeItem(at: file)
        }
    }

    func processQueue() async {
        guard currentTask == nil else { return }
        let task = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                let uploads = await (try? loadPendingUploads()) ?? []
                guard let upload = uploads.first else { break }
                do {
                    try await processUpload(upload)
                    await removeUploadFile(createdAt: upload.createdAt)
                } catch {
                    break
                }
            }
        }

        currentTask = task
        await task.value
        currentTask = nil
    }

    private let uploadStream: AsyncStream<(CheckIn.Id, ImageEntity.Saved)>
    private let continuation: AsyncStream<(CheckIn.Id, ImageEntity.Saved)>.Continuation
    var uploads: AsyncStream<(CheckIn.Id, ImageEntity.Saved)> {
        uploadStream
    }

    private func processUpload(_ upload: PendingUpload) async throws {
        let result = try await uploadImage(
            upload.checkInId,
            upload.imageData,
            upload.userId,
            upload.blurHash
        )
        continuation.yield((upload.checkInId, result))
        logger.info("Successfully uploaded image for check-in \(upload.checkInId.rawValue)")
    }

    deinit {
        continuation.finish()
    }
}
