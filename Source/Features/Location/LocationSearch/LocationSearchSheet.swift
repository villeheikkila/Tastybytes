
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
    @State private var searchResults = [Location.Saved]()
    @State private var searchTerm: String
    @State private var initialLocation: Location.Saved?

    let onSelect: (_ location: Location.Saved) -> Void

    init(initialLocation: Location.Saved?, initialSearchTerm: String?, onSelect: @escaping (_ location: Location.Saved) -> Void) {
        self.onSelect = onSelect
        searchTerm = initialSearchTerm ?? ""
        _initialLocation = State(initialValue: initialLocation)
    }

    var hasSearched: Bool {
        !searchTerm.isEmpty || initialLocation != nil
    }

    private var centerCoordinate: CLLocationCoordinate2D {
        initialLocation?.location?.coordinate ?? CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384)
    }

    private let radius: CLLocationDistance = 5000

    var body: some View {
        List {
            if state.isPopulated {
                ForEach(searchResults) { location in
                    LocationRow(location: location, currentLocation: nil, onSelect: { location in
                        onSelect(location)
                        dismiss()
                    })
                }
            }
        }
        .scrollContentBackground(.hidden)
        .searchable(text: $searchTerm)
        .overlay {
            ScreenStateOverlayView(state: state) {
                await loadInitialData()
            }
        }
        .navigationTitle("locations.search.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .task(id: searchTerm, milliseconds: 500) { [searchTerm] in
            guard !searchTerm.isEmpty else {
                searchResults = []
                return
            }
            await search(for: searchTerm, centerCoordinate: centerCoordinate)
        }
        .task {
            await loadInitialData()
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    func search(for query: String?, centerCoordinate: CLLocationCoordinate2D) async {
        if let query {
            do {
                searchResults = try await searchLocationsNatural(query: query, center: centerCoordinate, radius: radius)
                state = .populated
            } catch {
                logger.error("Error occured while looking up locations: \(error)")
                state = .error(error)
            }
        }
    }

    private nonisolated func searchLocationsNatural(query: String?, center: CLLocationCoordinate2D, radius: CLLocationDistance)
        async throws -> [Location.Saved]
    {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = [.pointOfInterest, .physicalFeature]
        request.region = .init(center: center, latitudinalMeters: radius, longitudinalMeters: radius)
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        return response.mapItems.map { .init(mapItem: $0) }
    }

    func loadInitialData() async {
        if initialLocation != nil {
            await search(for: searchTerm, centerCoordinate: centerCoordinate)
        }
    }
}
