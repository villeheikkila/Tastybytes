import Models

actor DeviceTokenActor {
    static let shared = DeviceTokenActor()

    var deviceTokenForPusNotifications: DeviceToken.Id?

    private init() {}

    func setDeviceTokenForPusNotifications(_ newValue: DeviceToken.Id?) async {
        deviceTokenForPusNotifications = newValue
    }
}
