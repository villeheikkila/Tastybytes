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
                if checkInModel.state.isPopulated {
                    CheckInListContentView(checkIns: $checkInModel.checkIns, onCreateCheckIn: { checkIn in
                        checkInModel.addNewCheckIn(checkIn)
                        try? await Task.sleep(for: .milliseconds(100))
                        proxy.scrollTo(checkIn.id, anchor: .top)
                    }, onLoadMore: {
                        await checkInModel.fetchFeedItems()
                    })
                    CheckInListLoadingIndicatorView(isLoading: $checkInModel.isLoading, isRefreshing: $checkInModel.isRefreshing)
                }
            }
            .listStyle(.plain)
            .animation(.easeIn, value: checkInModel.checkIns)
            .scrollIndicators(.hidden)
            .refreshable {
                await checkInModel.fetchFeedItems(reset: true, onPageLoad: false)
            }
            .checkInLoadedFrom(.activity(profileModel.profile))
            .sensoryFeedback(.success, trigger: checkInModel.isRefreshing) { oldValue, newValue in
                oldValue && !newValue
            }
            .overlay {
                if checkInModel.state.isPopulated {
                    if checkInModel.checkIns.isEmpty, !checkInModel.isLoading {
                        EmptyActivityFeedView()
                    }
                } else {
                    ScreenStateOverlayView(state: checkInModel.state) {
                        await checkInModel.fetchFeedItems(reset: true, onPageLoad: false)
                    }
                }
            }
            .toolbar {
                toolbarContent
            }
            .navigationTitle("tab.activity")
            .navigationBarTitleDisplayMode(.inline)
            .initialTask {
                await checkInModel.fetchFeedItems(onPageLoad: true)
            }
            .onChange(of: checkInModel.uploadedImageForCheckIn) { _, newValue in
                if let updatedCheckIn = newValue {
                    checkInModel.uploadedImageForCheckIn = nil
                    checkInModel.checkIns = checkInModel.checkIns.replacingWithId(updatedCheckIn.id, with: updatedCheckIn)
                }
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

@MainActor
@Observable
class CheckInModel {
    private let logger = Logger(label: "CheckInModel")
    private let repository: Repository
    
    var state: ScreenState = .loading
    var checkIns = [CheckIn.Joined]()
    private let onSnack: OnSnack
    var isRefreshing = false
    var isLoading = false
    
    @ObservationIgnored
    private let pageSize: Int
    
    init(
        repository: Repository,
        onSnack: @escaping OnSnack,
        pageSize: Int
    ) {
        self.repository = repository
        self.onSnack = onSnack
        self.pageSize = pageSize
    }
    
    func fetchFeedItems(reset: Bool = false, onPageLoad: Bool = false) async {
        if reset {
            isRefreshing = true
        } else {
            isLoading = true
        }
        
        let lastCheckInId = reset ? nil : checkIns.last?.id
        let startTime = DispatchTime.now()

        do {
            let fetchedCheckIns = try await repository.checkIn.getActivityFeed(
                id: lastCheckInId,
                pageSize: pageSize
            )
            guard !Task.isCancelled else { return }
            
            if reset {
                checkIns = fetchedCheckIns
            } else {
                checkIns.append(contentsOf: fetchedCheckIns)
            }
            state = .populated
            
            let queryDescription = if let lastCheckInId {
                "check-ins from cursor \(lastCheckInId.rawValue)"
            } else {
                "latest check-ins"
            }
            logger.info("Successfully loaded \(queryDescription), page size: \(pageSize) in \(startTime.elapsedTime())ms. Current feed length: \(checkIns.count)")
            
        } catch {
            guard !error.isCancelled, !Task.isCancelled else { return }
            logger.error("Fetching check-ins failed. Error: \(error) (\(#file):\(#line))")
            if state != .populated {
                state = .error(error)
            }
        }
        
        if reset {
            isRefreshing = false
        } else {
            isLoading = false
        }
    }
    
    func handleUploadedCheckIn(_ updatedCheckIn: CheckIn.Joined) {
        uploadedImageForCheckIn = nil
        checkIns = checkIns.replacingWithId(updatedCheckIn.id, with: updatedCheckIn)
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
