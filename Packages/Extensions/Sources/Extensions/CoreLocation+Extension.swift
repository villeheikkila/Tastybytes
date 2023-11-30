import CoreLocation

public extension CLLocationCoordinate2D {
    func getISOCountryCode() async throws -> String? {
        let geocoder = CLGeocoder()

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(CLLocation(
                latitude: latitude,
                longitude: longitude
            ))
            if let placemark = placemarks.first {
                return placemark.isoCountryCode
            } else {
                return nil
            }
        } catch {
            throw error
        }
    }
}
