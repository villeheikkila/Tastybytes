import CoreLocation
import Foundation
import MapKit
import Observation
import SwiftUI
import OSLog
import OSLog

struct LocationSearchSheet: View {
    private let logger = Logger(category: "LocationSearchView")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackManager.self) private var feedbackManager
    @State private var searchResults = [Location]()
    @State private var locationManager = LocationManager()
    @State private var recentLocations = [Location]()
    @State private var nearbyLocations = [Location]()
    @State private var searchText = ""

    @Environment(\.dismiss) private var dismiss

    let title: String
    let onSelect: (_ location: Location) -> Void

    init(title: String, onSelect: @escaping (_ location: Location) -> Void) {
        self.title = title
        self.onSelect = onSelect
    }

    var hasSearched: Bool {
        !searchText.isEmpty
    }

    private var center = CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384)
    private let radius: CLLocationDistance = 2000

    func search(for query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(center: center,
                                            latitudinalMeters: radius,
                                            longitudinalMeters: radius)

        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            let rawResults = response?.mapItems ?? []
            searchResults = rawResults.map { Location(mapItem: $0) }
        }
    }

    var body: some View {
        List {
            if !recentLocations.isEmpty, !hasSearched {
                Section("Recent locations") {
                    ForEach(recentLocations) { location in
                        LocationRow(location: location, onSelect: onSelect)
                    }
                }
            }
            if !recentLocations.isEmpty, !hasSearched {
                Section("Nearby locations") {
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
        .navigationTitle(title)
        .toolbar {
            toolbarContent
        }
        .onChange(of: searchText, debounceTime: 0.5, perform: { _ in
            search(for: searchText)
        })
        .task {
            await getRecentLocations()
        }
        .onChange(of: locationManager.location) { _, latestLocation in
            guard nearbyLocations.isEmpty else { return }
            Task { await getSuggestions(latestLocation) }
        }
    }
    
    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button("Cancel", role: .cancel, action: { dismiss() })
                .bold()
        }
    }

    func getRecentLocations() async {
        switch await repository.location.getRecentLocations() {
        case let .success(recentLocations):
            await MainActor.run {
                withAnimation {
                    self.recentLocations = recentLocations
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to load recemt locations. error: \(error)")
        }
    }

    func getSuggestions(_ location: CLLocation?) async {
        guard let location else { return }
        switch await repository.location.getSuggestions(location: Location.SuggestionParams(location: location)) {
        case let .success(nearbyLocations):
            await MainActor.run {
                withAnimation {
                    self.nearbyLocations = nearbyLocations
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("failed to load location suggestions. error: \(error)")
        }
    }
}

struct LocationRow: View {
    private let logger = Logger(category: "LocationSearchView")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackManager.self) private var feedbackManager
    @Environment(\.dismiss) private var dismiss

    let location: Location
    let onSelect: (_ location: Location) -> Void

    var body: some View {
        ProgressButton(action: {
            await storeLocation(location)
        }, label: {
            VStack(alignment: .leading) {
                Text(location.name)
                if let title = location.title {
                    Text(title)
                        .foregroundColor(.secondary)
                }
            }
        })
    }

    func storeLocation(_ location: Location) async {
        switch await repository.location.insert(location: location) {
        case let .success(savedLocation):
            onSelect(savedLocation)
            await MainActor.run {
                dismiss()
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("saving location \(location.name) failed. error: \(error)")
        }
    }
}
