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

@MainActor
struct LocationSearchSheet: View {
    private let logger = Logger(category: "LocationSearchView")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(LocationEnvironmentModel.self) private var locationEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchResults = [Location]()
    @State private var recentLocations = [Location]()
    @State private var nearbyLocations = [Location]()
    @State private var searchText = ""
    @State private var alertError: AlertError?
    @Binding private var initialLocation: Location?
    @State private var currentLocation: CLLocation?

    let category: Location.RecentLocation
    let title: LocalizedStringKey
    let onSelect: (_ location: Location) -> Void

    init(category: Location.RecentLocation, title: LocalizedStringKey, initialLocation: Binding<Location?>, onSelect: @escaping (_ location: Location) -> Void) {
        self.title = title
        self.onSelect = onSelect
        self.category = category
        _initialLocation = initialLocation
    }

    var hasSearched: Bool {
        !searchText.isEmpty || initialLocation != nil
    }

    private var centerCoordinate: CLLocationCoordinate2D {
        initialLocation?.location?.coordinate ?? currentLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384)
    }

    private let radius: CLLocationDistance = 2000

    var body: some View {
        List {
            if hasSearched {
                ForEach(searchResults) { location in
                    LocationSheetRow(location: location, currentLocation: currentLocation, onSelect: onSelect)
                }
            } else {
                if !recentLocations.isEmpty {
                    Section("location.recent") {
                        ForEach(recentLocations) { location in
                            LocationSheetRow(location: location, currentLocation: currentLocation, onSelect: onSelect)
                        }
                    }
                    .headerProminence(.increased)
                }
                if locationEnvironmentModel.hasAccess, !recentLocations.isEmpty {
                    Section("location.nearBy") {
                        ForEach(nearbyLocations) { location in
                            LocationSheetRow(location: location, currentLocation: currentLocation, onSelect: onSelect)
                        }
                    }
                    .headerProminence(.increased)
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
            do {
                let response = try await searchLocationsNatural(query: query, center: centerCoordinate, radius: radius)
                searchResults = response.mapItems.map { Location(mapItem: $0) }
            } catch {
                logger.error("Error occured while looking up locations: \(error)")
            }
        } else if let initialCoordinate = initialLocation?.location?.coordinate {
            do {
                let response = try await searchLocations(center: initialCoordinate, radius: radius)
                searchResults = response.mapItems.map { Location(mapItem: $0) }
            } catch {
                logger.error("Error occured while looking up locations: \(error)")
            }
        }
    }

    private nonisolated func searchLocationsNatural(query: String?, center: CLLocationCoordinate2D, radius: CLLocationDistance)
        async throws -> MKLocalSearch.Response
    {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = .init(center: center, latitudinalMeters: radius, longitudinalMeters: radius)
        let search = MKLocalSearch(request: request)
        return try await search.start()
    }

    private nonisolated func searchLocations(center: CLLocationCoordinate2D, radius: CLLocationDistance)
        async throws -> MKLocalSearch.Response
    {
        let request = MKLocalPointsOfInterestRequest(center: center, radius: radius)
        let search = MKLocalSearch(request: request)
        return try await search.start()
    }

    func loadInitialData() async {
        if initialLocation != nil {
            await search(for: nil)
        }
        currentLocation = await locationEnvironmentModel.getCurrentLocation()
        let coordinate = currentLocation?.coordinate ?? centerCoordinate
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
    let currentLocation: CLLocation?
    let onSelect: (_ location: Location) -> Void

    var body: some View {
        LocationRow(location: location, currentLocation: currentLocation) { location in
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
    let location: Location
    let currentLocation: CLLocation?
    let onSelect: (_ location: Location) -> Void

    var distance: Measurement<UnitLength>? {
        guard let currentLocation, let clLocation = location.location else { return nil }
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
            .contentShape(Rectangle())
            .accessibilityAddTraits(.isButton)
            .onTapGesture {
                onSelect(location)
            }
        }
        .listRowBackground(Color.clear)
    }
}

@MainActor
struct InitialLocationOverlay: View {
    @Binding var initialLocation: Location?

    var body: some View {
        if let coordinate = initialLocation?.location?.coordinate {
            HStack {
                Text("location.initialLocationOverlay.description \(coordinate.latitude.formatted(.number.precision(.fractionLength(2)))) \(coordinate.longitude.formatted(.number.precision(.fractionLength(2))))")
                Spacer()
                CloseButton {
                    initialLocation = nil
                }
                .labelStyle(.iconOnly)
                .imageScale(.large)
            }
            .padding()
            .background(.thinMaterial)
        }
    }
}
