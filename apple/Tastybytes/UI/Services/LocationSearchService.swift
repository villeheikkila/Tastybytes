import Combine
import CoreLocation
import Foundation
import MapKit

final class LocationSearchService {
  let localSearchPublisher = PassthroughSubject<[MKMapItem], Never>()
  private var center = CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384)
  private let radius: CLLocationDistance = 2000

  func setCenter(in center: CLLocationCoordinate2D) {
    self.center = center
  }

  func searchLocation(resultType: MKLocalSearch.ResultType = .pointOfInterest,
                      searchText: String)
  {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = searchText
    request.pointOfInterestFilter = .includingAll
    request.resultTypes = resultType
    request.region = MKCoordinateRegion(center: center,
                                        latitudinalMeters: radius,
                                        longitudinalMeters: radius)

    let search = MKLocalSearch(request: request)

    search.start { [weak self] response, _ in
      guard let response else {
        return
      }
      self?.localSearchPublisher.send(response.mapItems)
    }
  }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
  private let locationManager = CLLocationManager()
  @Published var locationStatus: CLAuthorizationStatus?
  @Published var lastLocation: CLLocation?

  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }

  var statusString: String {
    guard let status = locationStatus else {
      return "unknown"
    }

    switch status {
    case .notDetermined: return "notDetermined"
    case .authorizedWhenInUse: return "authorizedWhenInUse"
    case .authorizedAlways: return "authorizedAlways"
    case .restricted: return "restricted"
    case .denied: return "denied"
    default: return "unknown"
    }
  }

  func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    locationStatus = status
  }

  func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    lastLocation = location
  }
}
