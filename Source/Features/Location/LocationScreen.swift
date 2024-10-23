import Charts
import Components

import Extensions
import Logging
import MapKit
import Models
import PhotosUI
import Repositories
import SwiftUI

struct LocationScreen: View {
    private let logger = Logger(label: "LocationScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(AppModel.self) private var appModel
    @State private var state: ScreenState = .loading
    @State private var summary: Summary?
    @State private var location = Location.Saved()
    @State private var checkIns = [CheckIn.Joined]()
    @State private var isRefreshing = false
    @State private var isLoading = false
    @State private var page = 0
    @State private var onSegmentChangeTask: Task<Void, Error>?
    @State private var showCheckInsFrom: CheckIn.Segment = .everyone {
        didSet {
            onSegmentChangeTask?.cancel()
            onSegmentChangeTask = Task {
                await fetchCheckIns(reset: true, segment: showCheckInsFrom)
            }
        }
    }

    let id: Location.Id

    var body: some View {
        List {
            if state.isPopulated {
                content
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .animation(.default, value: location)
        .animation(.default, value: checkIns)
        .refreshable {
            await load(isRefresh: true)
        }
        .checkInLoadedFrom(.location(location))
        .overlay {
            ScreenStateOverlayView(state: state) {
                await load(isRefresh: true)
            }
        }
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if state.isPopulated {
                toolbarContent
            }
        }
        .initialTask {
            await load()
        }
    }

    @ViewBuilder private var content: some View {
        LocationScreenHeader(location: location, summary: summary)
        CheckInListSegmentPickerView(showCheckInsFrom: $showCheckInsFrom)
        CheckInListContentView(checkIns: $checkIns, onLoadMore: {
            await fetchCheckIns(segment: showCheckInsFrom)
        })
        CheckInListLoadingIndicatorView(isLoading: $isLoading, isRefreshing: $isRefreshing)
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        LocationToolbarItem(location: location)
        ToolbarItemGroup(placement: .topBarTrailing) {
            Menu {
                LocationShareLinkView(location: location)
                Divider()
                ReportButton(entity: .location(location))
                Divider()
                AdminRouterLink(open: .sheet(.locationAdmin(id: id, onEdit: { location in
                    self.location = .init(location: location)
                }, onDelete: { _ in
                    router.removeLast()
                })))
            } label: {
                Label("labels.menu", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
            }
        }
    }

    private func load(isRefresh _: Bool = false) async {
        async let checkInsPromise: Void = await fetchCheckIns(reset: true, segment: .everyone)
        async let locationPromise = repository.location.getById(id: id)
        async let summaryPromise = repository.location.getSummaryById(id: id)

        do {
            let (_, locationResult, summaryResult) = try await (checkInsPromise, locationPromise, summaryPromise)
            withAnimation {
                location = locationResult
                summary = summaryResult
                state = .populated
            }
        } catch {
            guard !error.isCancelled else { return }
            if state != .populated {
                state = .error(error)
            }
            logger.error("Failed to get summary. Error: \(error) (\(#file):\(#line))")
        }
    }

    func fetchCheckIns(reset: Bool = false, segment: CheckIn.Segment) async {
        let (from, to) = getPagination(page: reset ? 0 : page, size: appModel.rateControl.checkInPageSize)
        isLoading = true
        do {
            let fetchedCheckIns = try await repository.checkIn.getByLocation(id: id, segment: segment, from: from, to: to)
            if reset {
                checkIns = fetchedCheckIns
            } else {
                checkIns.append(contentsOf: fetchedCheckIns)
            }
            page += 1
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Fetching check-ins from \(from) to \(to) failed. Error: \(error) (\(#file):\(#line))")
            guard !error.isNetworkUnavailable else { return }
        }
        isLoading = false
    }
}

struct LocationScreenHeader: View {
    let location: Location.Saved
    let summary: Summary?

    var body: some View {
        if let coordinate = location.location?.coordinate {
            Map(initialPosition: MapCameraPosition
                .camera(.init(centerCoordinate: coordinate, distance: 200)))
            {
                Marker(location.name, coordinate: coordinate)
                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .frame(height: 200)
            .clipShape(.rect(cornerRadius: 8))
            .listRowInsets(.init(top: 8, leading: 4, bottom: 8, trailing: 4))
        }
        SummaryView(summary: summary)
    }
}

struct LocationScreenMap: View {
    let location: Location.Saved

    var body: some View {
        if let coordinate = location.location?.coordinate {
            Map(initialPosition: MapCameraPosition
                .camera(.init(centerCoordinate: coordinate, distance: 200)))
            {
                Marker(location.name, coordinate: coordinate)
                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .frame(height: 200)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 4, trailing: 0))
        }
    }
}

struct LocationToolbarItem: ToolbarContent {
    var location: Location.Saved

    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack {
                Text(location.name)
                    .font(.headline)
                if let title = location.title {
                    Text(title)
                        .font(.caption)
                }
            }
        }
    }
}
