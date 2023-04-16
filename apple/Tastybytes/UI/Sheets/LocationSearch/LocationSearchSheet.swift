import Combine
import MapKit
import SwiftUI

struct LocationSearchSheet: View {
  private let logger = getLogger(category: "LocationSearchView")
  @EnvironmentObject private var client: AppClient
  @StateObject private var viewModel: ViewModel
  @StateObject private var locationManager = LocationManager()
  @Environment(\.dismiss) private var dismiss

  var onSelect: (_ location: Location) -> Void

  init(onSelect: @escaping (_ location: Location) -> Void) {
    _viewModel = StateObject(wrappedValue: ViewModel())
    self.onSelect = onSelect
  }

  var body: some View {
    List(viewModel.locations) { location in
      ProgressButton(action: {
        await storeLocation(location, onSuccess: { savedLocation in
          onSelect(savedLocation)
          dismiss()
        })
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
    .navigationBarItems(trailing: Button("Cancel", role: .cancel, action: {
      dismiss()
    }))
    .navigationTitle("Location")
    .searchable(text: $viewModel.searchText)
    .task {
      guard let lastLocation = locationManager.lastLocation else { return }
      viewModel.setInitialLocation(lastLocation)
      await getSuggestions(lastLocation)
    }
  }

  func getSuggestions(_ location: CLLocation?) async {
    guard let location else { return }
    switch await client.location.getSuggestions(location: Location.SuggestionParams(location: location)) {
    case let .success(suggestedLocations):
      viewModel.locations = suggestedLocations
    case let .failure(error):
      logger.error("failed to load location suggestions: \(error.localizedDescription)")
    }
  }

  func storeLocation(_ location: Location, onSuccess: @escaping (_ savedLocation: Location) -> Void) async {
    switch await client.location.insert(location: location) {
    case let .success(savedLocation):
      onSuccess(savedLocation)
    case let .failure(error):
      logger.error("saving location \(location.name) failed: \(error.localizedDescription)")
    }
  }
}

extension LocationSearchSheet {
  @MainActor
  class ViewModel: ObservableObject {
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
}
