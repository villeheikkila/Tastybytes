import Components
import Extensions
import Logging
import Models
import Repositories
import SwiftUI

struct ActivityScreen: View {
    private let logger = Logger(label: "CheckInList")
    @Environment(CheckInModel.self) private var checkInModel

    var body: some View {
        @Bindable var checkInModel = checkInModel
        TabView(selection: $checkInModel.segment) {
            Tab(value: .all) {
                ActivityAllEventsListView(segment: .all)
            }
            Tab(value: .you) {
                ActivityAllEventsListView(segment: .you)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .toolbar {
            ToolbarItem(placement: .principal) {
                SegmentPickerView(currentTab: $checkInModel.segment)
                    .frame(width: 300)
            }
        }
        .navigationTitle("tab.activity")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await checkInModel.listenToCheckInImageUploads()
        }
    }
}

struct FriendRouterLinkWithUnreadCountBadgeView: View {
    @Environment(ProfileModel.self) private var profileModel

    var body: some View {
        RouterLink("friends.navigationTitle", systemImage: "person.2", open: .screen(.currentUserFriends))
            .labelStyle(.iconOnly)
            .imageScale(.large)
            .customBadge(profileModel.unreadFriendRequestCount)
    }
}

struct ActivityAllEventsListView: View {
    private let logger = Logger(label: "ActivityAllEventsListView")
    @Environment(CheckInModel.self) private var checkInModel
    @Environment(ProfileModel.self) private var profileModel
    let segment: ActivitySegment

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(checkInModel.currentCheckIns) { checkIn in
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
                        checkInModel.onNewActiveItem(checkIn, segment: segment)
                    }
                }
                ActivityLoadingIndicatorView(state: checkInModel.currentState) {
                    await checkInModel.fetchFeedItems(mode: .retry, segment: segment)
                }
            }
            .listStyle(.plain)
            .animation(.easeIn, value: checkInModel.currentCheckIns)
            .scrollIndicators(.hidden)
            .refreshable {
                await checkInModel.fetchFeedItems(mode: .reset, segment: segment)
            }
            .overlay {
                switch checkInModel.currentState {
                case let .error(error):
                    ScreenContentUnavailableView(error: error, description: nil) {
                        await checkInModel.fetchFeedItems(mode: .reset, segment: segment)
                    }
                case .loading:
                    ScreenLoadingView()
                case .populated where checkInModel.currentCheckIns.isEmpty:
                    EmptyActivityFeedView()
                default:
                    EmptyView()
                }
            }
            .initialTask {
                await checkInModel.fetchFeedItems(mode: .pageLoad, segment: segment)
            }
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

enum ActivitySegment: Equatable, Identifiable, CaseIterable, SegmentPickerItem {
    case all
    case you

    var id: String {
        switch self {
        case .all:
            "all"
        case .you:
            "you"
        }
    }

    var label: String {
        switch self {
        case .all:
            "Activity"
        case .you:
            "You"
        }
    }
}

@MainActor
@Observable
class CheckInModel {
    private let logger = Logger(label: "CheckInModel")
    // observable state
    var segment: ActivitySegment = .all
    var currentState: ActivityState {
        get { segment == .all ? allTabState.state : youTabState.state }
        set {
            if segment == .all {
                allTabState.state = newValue
            } else {
                youTabState.state = newValue
            }
        }
    }

    var currentCheckIns: [CheckIn.Joined] {
        get { segment == .all ? allTabState.checkIns : youTabState.checkIns }
        set {
            if segment == .all {
                allTabState.checkIns = newValue
            } else {
                youTabState.checkIns = newValue
            }
        }
    }

    // state
    private struct TabState {
        var state: ActivityState = .loading
        var checkIns: [CheckIn.Joined] = []
        var task: Task<Void, Never>?
    }

    private var allTabState = TabState()
    private var youTabState = TabState()
    // depedencies
    private let repository: Repository
    private let onSnack: OnSnack
    // options
    private let pageSize: Int
    private let loadMoreThreshold: Int
    // task management
    private let uploadQueue: UploadQueue

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

    private func updateBothArrays(_ update: (inout [CheckIn.Joined]) -> Void) {
        update(&allTabState.checkIns)
        update(&youTabState.checkIns)
    }

    func onCreateCheckIn(_ item: CheckIn.Joined, scrollProxy: ScrollViewProxy) async {
        updateBothArrays { checkIns in
            checkIns = [item] + checkIns
        }
        try? await Task.sleep(for: .milliseconds(100))
        scrollProxy.scrollTo(item.id, anchor: .top)
    }

    func onUpdateCheckIn(_ item: CheckIn.Joined) async {
        updateBothArrays { checkIns in
            checkIns = checkIns.replacingWithId(item.id, with: item)
        }
    }

    func onDeleteCheckIn(_ item: CheckIn.Joined) async {
        do {
            try await repository.checkIn.delete(id: item.id)
            updateBothArrays { checkIns in
                checkIns.remove(object: item)
            }
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Deleting check-in failed. Error: \(error) (\(#file):\(#line))")
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle", message: "checkIn.delete.failure.alert")))
        }
    }

    func onNewActiveItem(_ item: CheckIn.Joined, segment: ActivitySegment) {
        let checkIns = segment == .all ? allTabState.checkIns : youTabState.checkIns
        let numberOfCheckIns = checkIns.count
        let index = checkIns.firstIndex { $0.id == item.id }
        guard let index, index + loadMoreThreshold > numberOfCheckIns else { return }
        Task {
            await fetchFeedItems(mode: .loadMore(item.id), segment: segment)
        }
    }

    func fetchFeedItems(mode: FetchFeedMode, segment: ActivitySegment) async {
        let tabState = segment == .all ? allTabState : youTabState
        guard mode == .reset || tabState.task == nil else { return }
        if segment == .all {
            allTabState.task?.cancel()
            allTabState.task = nil
        } else {
            youTabState.task?.cancel()
            youTabState.task = nil
        }
        let currentCheckIns = segment == .all ? allTabState.checkIns : youTabState.checkIns
        let task = Task {
            currentState = switch mode {
            case .pageLoad where currentCheckIns.isEmpty: .loading
            case .reset: .refreshing
            case .loadMore, .pageLoad, .retry: .loadingMore
            }
            do {
                let startTime = DispatchTime.now()
                let cursor = mode == .reset ? nil : currentCheckIns.last?.id
                let fetchedCheckIns = try await repository.checkIn.getActivityFeed(
                    id: cursor,
                    pageSize: pageSize,
                    filter: segment == .all ? .both : .currentUser
                )
                guard !Task.isCancelled else { return }
                withAnimation(.easeIn) {
                    let newCheckIns = mode == .reset ? fetchedCheckIns : currentCheckIns + fetchedCheckIns
                    if segment == .all {
                        allTabState.checkIns = newCheckIns
                        allTabState.state = .populated
                    } else {
                        youTabState.checkIns = newCheckIns
                        youTabState.state = .populated
                    }
                }
                logger.info("Successfully loaded check-ins\(cursor.map { " from cursor \($0.rawValue)" } ?? ""), page size: \(pageSize) in \(startTime.elapsedTime())ms. Current feed length: \(currentCheckIns.count)")
            } catch {
                guard !error.isCancelled else { return }
                logger.error("Fetching check-ins failed. Error: \(error) (\(#file):\(#line))")
                let newState: ActivityState = switch currentState {
                case .loading, .refreshing, .error:
                    .error(error)
                case .loadingMore, .errorLoadingMore:
                    .errorLoadingMore(error)
                case .populated:
                    currentCheckIns.isEmpty ? .error(error) : .errorLoadingMore(error)
                }
                currentState = newState
            }
        }
        if segment == .all {
            allTabState.task = task
        } else {
            youTabState.task = task
        }
        await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            task.cancel()
        }
        if segment == .all {
            allTabState.task = nil
        } else {
            youTabState.task = nil
        }
    }

    func uploadCheckInImage(checkIn: CheckIn.Joined, images: [UIImage]) {
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

    func listenToCheckInImageUploads() async {
        for await (checkInId, image) in await uploadQueue.uploads {
            updateBothArrays { checkIns in
                if let index = checkIns.firstIndex(where: { $0.id == checkInId }) {
                    let updatedCheckIn = checkIns[index].copyWith(images: checkIns[index].images + [image])
                    checkIns[index] = updatedCheckIn
                }
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
