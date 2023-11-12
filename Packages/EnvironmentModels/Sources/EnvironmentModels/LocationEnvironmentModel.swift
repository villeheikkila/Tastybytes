import CoreLocation
import MapKit
import Observation
import OSLog

@Observable
public final class LocationEnvironmentModel {
    private let logger = Logger(category: "LocationEnvironmentModel")
    private let manager = CLLocationManager()
    public var location: CLLocation? = nil

    public init() {}

    public func updateLocation() async {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        logger.info("Updating location...")
        let updates = CLLocationUpdate.liveUpdates()
        do {
            for try await update in updates {
                if let location = update.location {
                    self.location = location
                    logger.info("Location found, stopping.")
                    break
                }
            }
        } catch {
            logger.error("Error occured while trying to read current location")
        }
    }
}
