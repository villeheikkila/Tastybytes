import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct ActivityScreen: View {
    enum ScreenState {
        case initial, initialized
    }

    private let logger = Logger(category: "CheckInList")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(ImageUploadEnvironmentModel.self) private var imageUploadEnvironmentModel
    @Binding var scrollToTop: Int
    @State private var checkInLoader: CheckInListLoader
    @State private var screenState: ScreenState = .initial

    init(repository: Repository, scrollToTop: Binding<Int>) {
        _checkInLoader = State(initialValue: CheckInListLoader(fetcher: { from, to, _ in
            await repository.checkIn.getActivityFeed(from: from, to: to)
        }, id: "ActivityScreen"))
        _scrollToTop = scrollToTop
    }

    var body: some View {
        @Bindable var imageUploadEnvironmentModel = imageUploadEnvironmentModel
        ScrollViewReader { proxy in
            List {
                CheckInListContent(checkIns: $checkInLoader.checkIns, alertError: $checkInLoader.alertError, loadedFrom: .activity(profileEnvironmentModel.profile), onCheckInUpdate: checkInLoader.onCheckInUpdate, onCreateCheckIn: { checkIn in
                    checkInLoader.onCreateCheckIn(checkIn)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        proxy.scrollTo(checkIn.id, anchor: .top)
                    }
                }, onLoadMore: {
                    checkInLoader.onLoadMore()
                })
                CheckInListLoadingIndicator(isLoading: $checkInLoader.isLoading, isRefreshing: $checkInLoader.isRefreshing)
            }
            .listStyle(.plain)
            .defaultScrollContentBackground()
            .scrollIndicators(.hidden)
            .refreshable {
                await checkInLoader.fetchFeedItems(reset: true)
            }
            .sensoryFeedback(.success, trigger: checkInLoader.isRefreshing) { oldValue, newValue in
                oldValue && !newValue
            }
            .overlay {
                if checkInLoader.errorContentUnavailable != nil {
                    ContentUnavailableView {
                        Label("activity.error.failedToLoad", systemImage: "exclamationmark.triangle")
                    } actions: {
                        ProgressButton("labels.reload") {
                            await checkInLoader.fetchFeedItems(reset: true)
                        }
                    }
                } else if screenState == .initialized, checkInLoader.checkIns.isEmpty, !checkInLoader.isLoading {
                    EmptyActivityFeedView()
                }
            }
            .alertError($checkInLoader.alertError)
            .onChange(of: scrollToTop) {
                guard let first = checkInLoader.checkIns.first else { return }
                withAnimation {
                    proxy.scrollTo(first.id, anchor: .top)
                }
            }
            .task {
                if screenState == .initial {
                    await checkInLoader.loadData()
                    screenState = .initialized
                }
            }
            .onChange(of: imageUploadEnvironmentModel.uploadedImageForCheckIn) { _, newValue in
                if let updatedCheckIn = newValue {
                    imageUploadEnvironmentModel.uploadedImageForCheckIn = nil
                    checkInLoader.onCheckInUpdate(updatedCheckIn)
                }
            }
        }
    }
}
