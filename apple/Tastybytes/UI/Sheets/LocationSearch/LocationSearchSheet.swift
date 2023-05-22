import Combine
import MapKit
import SwiftUI

struct LocationSearchSheet: View {
  private let logger = getLogger(category: "LocationSearchView")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @StateObject private var viewModel = ViewModel()
  @StateObject private var locationManager = LocationManager()
  @State private var recentLocations = [Location]()
  @State private var nearbyLocations = [Location]()
  @State private var searchText = ""
  @Environment(\.dismiss) private var dismiss

  let title: String
  let onSelect: (_ location: Location) -> Void

  var hasSearched: Bool {
    !viewModel.searchText.isEmpty
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
        ForEach(viewModel.locations) { location in
          LocationRow(location: location, onSelect: onSelect)
        }
      }
    }
    .navigationBarItems(trailing: Button("Cancel", role: .cancel, action: {
      dismiss()
    }))
    .navigationTitle(title)
    .searchable(text: $searchText)
    .onChange(of: searchText, debounceTime: 0.5, perform: { _ in
      viewModel.searchText = searchText
    })
    .task {
      await getRecentLocations()
    }
    .onChange(of: locationManager.lastLocation, perform: { _ in
      guard nearbyLocations.isEmpty else { return }
      guard let lastLocation = locationManager.lastLocation else { return }
      viewModel.setInitialLocation(lastLocation)
      Task { await getSuggestions(lastLocation) }
    })
  }

  func getRecentLocations() async {
    switch await repository.location.getRecentLocations() {
    case let .success(recentLocations):
      withAnimation {
        self.recentLocations = recentLocations
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to load recemt locations: \(error.localizedDescription)")
    }
  }

  func getSuggestions(_ location: CLLocation?) async {
    guard let location else { return }
    switch await repository.location.getSuggestions(location: Location.SuggestionParams(location: location)) {
    case let .success(nearbyLocations):
      withAnimation {
        self.nearbyLocations = nearbyLocations
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to load location suggestions: \(error.localizedDescription)")
    }
  }
}

extension LocationSearchSheet {
  @MainActor
  final class ViewModel: ObservableObject {
    var service: LocationSearchManager
    private var cancellable: AnyCancellable?
    @Published var locations = [Location]()
    @Published var searchText = "" {
      didSet {
        searchForLocation(text: searchText)
      }
    }

    init() {
      service = LocationSearchManager()
      cancellable = service.localSearchPublisher.sink { mapItems in
        self.locations = mapItems.map { Location(mapItem: $0) }
      }
    }

    func setInitialLocation(_ location: CLLocation?) {
      let latitude = location?.coordinate.latitude ?? 60.1699
      let longitutde = location?.coordinate.longitude ?? 24.9384
      let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitutde)
      service.setCenter(in: center)
    }

    private func searchForLocation(text _: String) {
      service.searchLocation(searchText: searchText, resultType: .pointOfInterest)
    }
  }

  struct LocationRow: View {
    private let logger = getLogger(category: "LocationSearchView")
    @EnvironmentObject private var repository: Repository
    @EnvironmentObject private var feedbackManager: FeedbackManager
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
        dismiss()
      case let .failure(error):
        guard !error.localizedDescription.contains("cancelled") else { return }
        feedbackManager.toggle(.error(.unexpected))
        logger.error("saving location \(location.name) failed: \(error.localizedDescription)")
      }
    }
  }
}
