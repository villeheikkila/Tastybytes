import Components
import Extensions
import Logging
import Models
import Repositories
import SwiftUI

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
