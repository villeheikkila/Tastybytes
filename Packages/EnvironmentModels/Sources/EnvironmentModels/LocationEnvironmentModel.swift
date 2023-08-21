import CoreLocation
import MapKit
import Observation

@Observable
public final class LocationEnvironmentModel: NSObject {
    private let locationEnvironmentModel = CLLocationManager()

    public var location: CLLocation? = nil

    override public init() {
        super.init()
        locationEnvironmentModel.desiredAccuracy = kCLLocationAccuracyBest
        locationEnvironmentModel.distanceFilter = kCLDistanceFilterNone
        locationEnvironmentModel.requestWhenInUseAuthorization()
        locationEnvironmentModel.startUpdatingLocation()
        locationEnvironmentModel.delegate = self
    }
}

extension LocationEnvironmentModel: CLLocationManagerDelegate {
    func locationEnvironmentModel(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.location = location
        }
    }
}
