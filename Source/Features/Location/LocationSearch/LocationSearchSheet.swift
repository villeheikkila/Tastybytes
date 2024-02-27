import Components
import CoreLocation
import EnvironmentModels
import Extensions
import Foundation
import MapKit
import Models
import OSLog
import Repositories
import SwiftUI

// HACK: Remove when no longer necessary
extension MKLocalSearch.Response: @unchecked Sendable {}

@MainActor
struct LocationSearchSheet: View {
    private let logger = Logger(category: "LocationSearchView")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(PermissionEnvironmentModel.self) private var permissionEnvironmentModel
    @Environment(LocationEnvironmentModel.self) private var locationEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchResults = [Location]()
    @State private var recentLocations = [Location]()
    @State private var nearbyLocations = [Location]()
    @State private var searchText = ""
    @State private var alertError: AlertError?
    @State private var initialLocation: CLLocationCoordinate2D?

    let category: Location.RecentLocation
    let title: LocalizedStringKey
    let onSelect: (_ location: Location) -> Void

    init(category: Location.RecentLocation, title: LocalizedStringKey, initialLocation: CLLocationCoordinate2D?, onSelect: @escaping (_ location: Location) -> Void) {
        self.title = title
        self.onSelect = onSelect
        self.category = category
        _initialLocation = State(initialValue: initialLocation)
    }

    var hasSearched: Bool {
        !searchText.isEmpty || initialLocation != nil
    }

    private var centerCoordinate: CLLocationCoordinate2D {
        initialLocation ?? locationEnvironmentModel.location?.coordinate ?? CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384)
    }

    private let radius: CLLocationDistance = 2000

    var body: some View {
        List {
            if !recentLocations.isEmpty, !hasSearched {
                Section("location.recent") {
                    ForEach(recentLocations) { location in
                        LocationRow(location: location, onSelect: onSelect)
                    }
                }
            }
            if locationEnvironmentModel.hasAccess, !recentLocations.isEmpty, !hasSearched {
                Section("location.nearBy") {
                    ForEach(nearbyLocations) { location in
                        LocationRow(location: location, onSelect: onSelect)
                    }
                }
            }
            if hasSearched {
                ForEach(searchResults) { location in
                    LocationRow(location: location, onSelect: onSelect)
                }
            }
        }
        .searchable(text: $searchText)
        .safeAreaInset(edge: .bottom, alignment: .trailing) {
            if initialLocation != nil {
                InitialLocationOverlay(initialLocation: $initialLocation)
            }
        }
        .navigationTitle(title)
        .toolbar {
            toolbarContent
        }
        .task(id: searchText, milliseconds: 500) { @MainActor [searchText] in
            guard initialLocation == nil else { return }
            guard !searchText.isEmpty else {
                searchResults = []
                return
            }
            await search(for: searchText)
        }
        .task {
            await loadInitialData()
        }
        .alertError($alertError)
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    func search(for query: String?) async {
        if let query {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.resultTypes = .pointOfInterest
            request.region = .init(center: centerCoordinate, latitudinalMeters: radius, longitudinalMeters: radius)
            let search = MKLocalSearch(request: request)
            do {
                let response = try await search.start()
                searchResults = response.mapItems.map { Location(mapItem: $0) }
            } catch {
                logger.error("Error occured while looking up locations: \(error)")
            }
        } else if let initialLocation {
            let request = MKLocalPointsOfInterestRequest(center: initialLocation, radius: radius)
            let search = MKLocalSearch(request: request)
            do {
                let response = try await search.start()
                searchResults = response.mapItems.map { Location(mapItem: $0) }
            } catch {
                logger.error("Error occured while looking up locations: \(error)")
            }
        }
    }

    func loadInitialData() async {
        if initialLocation != nil {
            await search(for: nil)
        }
        let coordinate = await locationEnvironmentModel.getCurrentLocation()?.coordinate ?? centerCoordinate
        async let recentLocationsPromise = repository.location.getRecentLocations(category: category)
        async let suggestionsPromise = repository.location.getSuggestions(location: Location.SuggestionParams(coordinate: coordinate))

        let (recentLocationsResult, suggestionResult) = await (recentLocationsPromise, suggestionsPromise)

        switch suggestionResult {
        case let .success(nearbyLocations):
            withAnimation {
                self.nearbyLocations = nearbyLocations
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to load location suggestions. Error: \(error) (\(#file):\(#line))")
        }
        switch recentLocationsResult {
        case let .success(recentLocations):
            withAnimation {
                self.recentLocations = recentLocations
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to load recemt locations. Error: \(error) (\(#file):\(#line))")
        }
    }
}

@MainActor
struct LocationSheetRow: View {
    private let logger = Logger(category: "LocationSearchView")
    @Environment(Repository.self) private var repository
    @Environment(\.dismiss) private var dismiss
    @State private var alertError: AlertError?

    let location: Location
    let onSelect: (_ location: Location) -> Void

    var body: some View {
        LocationRow(location: location) { location in
            Task {
                await storeLocation(location)
            }
        }
        .alertError($alertError)
    }

    func storeLocation(_ location: Location) async {
        switch await repository.location.insert(location: location) {
        case let .success(savedLocation):
            onSelect(savedLocation)
            dismiss()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Saving location \(location.name) failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}

@MainActor
struct LocationRow: View {
    @Environment(LocationEnvironmentModel.self) private var locationEnvironmentModel

    let location: Location
    let onSelect: (_ location: Location) -> Void

    var distance: Measurement<UnitLength>? {
        guard let currentLocation = locationEnvironmentModel.location, let clLocation = location.location else { return nil }
        let distanceInMeters = currentLocation.distance(from: clLocation)
        return .init(value: distanceInMeters, unit: UnitLength.meters)
    }

    var body: some View {
        HStack {
            if let coordinate = location.location?.coordinate {
                MapThumbnail(location: location, coordinate: coordinate, distance: distance)
            }
            VStack(alignment: .leading) {
                Text(location.name)
                if let title = location.title {
                    Text(title)
                        .foregroundColor(.secondary)
                }
                if let distance {
                    Text("location.distance \(distance, format: .measurement(width: .narrow))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .onTapGesture {
                onSelect(location)
            }
        }
        .listRowBackground(Color.clear)
    }
}

@MainActor
struct InitialLocationOverlay: View {
    @Binding var initialLocation: CLLocationCoordinate2D?

    var body: some View {
        if let coordinate = initialLocation {
            HStack {
                VStack(alignment: .leading) {
                    Text("location.initialLocationOverlay.description \(coordinate.latitude.formatted(.number.precision(.fractionLength(2)))) \(coordinate.longitude.formatted(.number.precision(.fractionLength(2))))")
                }
                Spacer()
                CloseButton {
                    initialLocation = nil
                }
                .labelStyle(.iconOnly)
                .imageScale(.large)
            }
            .padding(.horizontal, 10)
            .background(.thinMaterial)
        }
    }
}
