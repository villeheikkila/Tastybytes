import CoreLocation
import MapKit
public import Tagged

public enum Location {}

public extension Location {
    typealias Id = Tagged<Location, UUID>
}
