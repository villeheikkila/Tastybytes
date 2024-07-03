import EnvironmentModels
import MapKit
import Models
import OSLog
import Repositories
import SwiftUI

struct LocationSearchSheet: View {
    private let logger = Logger(category: "LocationSearchSheet")
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var state: ScreenState = .loading
    @State private var searchResults = [Location]()
    @State private var searchText: String
    @State private var initialLocation: Location?

    let onSelect: (_ location: Location) -> Void

    init(initialLocation: Location?, initialSearchTerm: String?, onSelect: @escaping (_ location: Location) -> Void) {
        self.onSelect = onSelect
        searchText = initialSearchTerm ?? ""
        _initialLocation = State(initialValue: initialLocation)
    }

    var hasSearched: Bool {
        !searchText.isEmpty || initialLocation != nil
    }

    private var centerCoordinate: CLLocationCoordinate2D {
        initialLocation?.location?.coordinate ?? CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384)
    }

    private let radius: CLLocationDistance = 2000

    var body: some View {
        List {
            if state == .populated {
                ForEach(searchResults) { location in
                    LocationRow(location: location, currentLocation: nil, onSelect: { location in
                        onSelect(location)
                        dismiss()
                    })
                }
            }
        }
        .scrollContentBackground(.hidden)
        .searchable(text: $searchText)
        .overlay {
            ScreenStateOverlayView(state: state, errorDescription: "") {
                await loadInitialData()
            }
        }
        .navigationTitle("locations.search.title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .task(id: searchText, milliseconds: 500) { [searchText] in
            guard !searchText.isEmpty else {
                searchResults = []
                return
            }
            await search(for: searchText)
        }
        .task {
            await loadInitialData()
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    func search(for query: String?) async {
        if let query {
            do {
                searchResults = try await searchLocationsNatural(query: query, center: centerCoordinate, radius: radius)
                state = .populated
            } catch {
                logger.error("Error occured while looking up locations: \(error)")
                state = .error([error])
            }
        }
    }

    private nonisolated func searchLocationsNatural(query: String?, center: CLLocationCoordinate2D, radius: CLLocationDistance)
        async throws -> [Location]
    {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = .init(center: center, latitudinalMeters: radius, longitudinalMeters: radius)
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        return response.mapItems.map { Location(mapItem: $0) }
    }

    func loadInitialData() async {
        if initialLocation != nil {
            await search(for: searchText)
        }
    }
}
