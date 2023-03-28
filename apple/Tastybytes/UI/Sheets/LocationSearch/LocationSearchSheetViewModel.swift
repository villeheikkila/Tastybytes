import Combine
import MapKit
import SwiftUI

extension LocationSearchSheet {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "LocationSearchView")
    let client: Client
    var service: LocationSearchManager
    private var cancellable: AnyCancellable?
    @Published var locations = [Location]()
    @Published var searchText = "" {
      didSet {
        searchForLocation(text: searchText)
      }
    }

    init(_ client: Client) {
      self.client = client
      service = LocationSearchManager()
      cancellable = service.localSearchPublisher.sink { mapItems in
        self.locations = mapItems.map { Location(mapItem: $0) }
      }
    }

    func getSuggestions(_ location: CLLocation?) async {
      guard let location else { return }
      switch await client.location.getSuggestions(location: Location.SuggestionParams(location: location)) {
      case let .success(suggestedLocations):
        locations = suggestedLocations
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
