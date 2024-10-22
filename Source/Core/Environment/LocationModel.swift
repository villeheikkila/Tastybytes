import CoreLocation
import MapKit
import Logging

@MainActor
@Observable
public final class LocationModel {
    private let logger = Logger(label: "LocationModel")
    private let manager = CLLocationManager()
    private var monitoringTask: Task<Void, Never>?

    public var location: CLLocation?
    public var locationsStatus: CLAuthorizationStatus = .notDetermined

    public init() {}

    public var hasAccess: Bool {
        locationsStatus == .authorizedAlways || locationsStatus == .authorizedWhenInUse
    }

    public func requestLocationAuthorization() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }

    public func updateLocationAuthorizationStatus() {
        locationsStatus = manager.authorizationStatus
    }

    public func startMonitoringLocationStatus() {
        logger.info("Starting location status monitoring...")
        let initialStatus = locationsStatus
        monitoringTask = Task {
            while true {
                updateLocationAuthorizationStatus()
                if locationsStatus != initialStatus {
                    logger.info("Location status changed")
                    break
                }
                logger.info("Location status updated")
                try? await Task.sleep(for: .milliseconds(500))
            }
        }
    }

    public func stopMonitoringLocationStatus() {
        logger.info("Stopping location status monitoring...")
        monitoringTask?.cancel()
    }

    public func updateLocation() async {
        requestLocationAuthorization()
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

    public func getCurrentLocation() async -> CLLocation? {
        requestLocationAuthorization()
        let updates = CLLocationUpdate.liveUpdates()
        do {
            for try await update in updates {
                if let location = update.location {
                    logger.info("Current location: \(location)")
                    self.location = location
                    return location
                }
            }
        } catch {
            logger.error("Error occured while trying to read current location")
        }
        return nil
    }
}
