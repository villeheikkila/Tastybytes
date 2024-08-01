public import Tagged

public enum DeviceToken {}

public extension DeviceToken {
    typealias Id = Tagged<DeviceToken, String>
}
