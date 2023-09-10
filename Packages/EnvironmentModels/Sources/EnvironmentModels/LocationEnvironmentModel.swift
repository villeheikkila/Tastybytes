import CoreLocation
import MapKit
import Observation
import OSLog

@Observable
public final class LocationEnvironmentModel: NSObject, CLLocationManagerDelegate {
    private let logger = Logger(category: "LocationEnvironmentModel")
    private let manager = CLLocationManager()

    public var location: CLLocation? = nil

    override public init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.delegate = self
    }

    public func requestLocation() {
        manager.requestLocation()
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        manager.stopUpdatingLocation()
    }

    public func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        logger.debug("Error while trying to get current location: \(error)")
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        }
    }
}
