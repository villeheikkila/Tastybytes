import Components
import Extensions
import Logging
import Models
import Repositories
import SwiftUI

@MainActor
@Observable
class CheckInModel {
    private let logger = Logger(label: "CheckInModel")
    // observable state
    var profileSummary: Profile.Summary?
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
    // profile
    private var profileId: Profile.Id?

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

    func onCreateCheckIn(_ item: CheckIn.Joined, scrollProxy: ScrollViewProxy? = nil) async {
        updateBothArrays { checkIns in
            checkIns = [item] + checkIns
        }
        guard let scrollProxy else { return }
        try? await Task.sleep(for: .milliseconds(100))
        scrollProxy.scrollTo(item.id, anchor: .top)
    }

    func onUpdateCheckIn(_ item: CheckIn.Joined) {
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

    func initialize(id: Profile.Id? = nil) async {
        profileId = profileId ?? id
        guard let profileId else {
            logger.error("Model must be intialized before it can be used without an id. (\(#file):\(#line))")
            return
        }
        let startTime = DispatchTime.now()
        async let allSegment: Void = fetchFeedItems(mode: .pageLoad, segment: .all)
        async let youSegment: Void = fetchFeedItems(mode: .pageLoad, segment: .you)
        async let summary = repository.checkIn.getSummaryByProfileId(id: profileId)
        do {
            profileSummary = try await summary
            await allSegment
            await youSegment
            logger.info("Check-in model loaded in \(startTime.elapsedTime())ms")
            for await (checkInId, image) in await uploadQueue.uploads {
                updateBothArrays { checkIns in
                    if let index = checkIns.firstIndex(where: { $0.id == checkInId }) {
                        let updatedCheckIn = checkIns[index].copyWith(images: checkIns[index].images + [image])
                        withAnimation {
                            checkIns[index] = updatedCheckIn
                        }
                    }
                }
            }
        } catch {
            logger.error("Initializing check-in model failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func refresh() async {
        guard let profileId else {
            logger.error("Model must be intialized before it can be refreshed. (\(#file):\(#line))")
            return
        }
        let startTime = DispatchTime.now()
        do {
            let summaryResult = try await repository.checkIn.getSummaryByProfileId(id: profileId)
            logger.info("Check-in model refreshed in \(startTime.elapsedTime())ms")
            withAnimation {
                profileSummary = summaryResult
            }
        } catch {
            logger.error("Refreshing check-in model failed. Error: \(error) (\(#file):\(#line))")
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

    func createCheckIn(checkIn: CheckIn.NewRequest, images: [UIImage]) async throws -> CheckIn.Joined {
        let checkIn = try await repository.checkIn.create(newCheckInParams: checkIn)
        uploadCheckInImage(checkIn: checkIn, images: images)
        await onCreateCheckIn(checkIn)
        return checkIn
    }

    func updateCheckIn(update: CheckIn.UpdateRequest, images: [UIImage]) async throws -> CheckIn.Joined {
        let checkIn = try await repository.checkIn.update(updateCheckInParams: update)
        uploadCheckInImage(checkIn: checkIn, images: images)
        onUpdateCheckIn(checkIn)
        return checkIn
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

    var tab: Tab<Self, some View, some View> {
        Tab(value: self) {
            ActivityListView(segment: self)
                .toolbarVisibility(.hidden, for: .tabBar)
        }
    }
}
