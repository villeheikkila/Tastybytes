import AVFoundation
import OSLog
import SwiftUI

@MainActor
@Observable
public final class PermissionEnvironmentModel {
    private let logger = Logger(category: "PermissionEnvironmentModel")
    private let notificationEnvironmentModel = UNUserNotificationCenter.current()

    public var pushNotificationStatus: UNAuthorizationStatus = .notDetermined

    public init() {}

    // push notifications
    public func requestPushNotificationAuthorization() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        notificationEnvironmentModel.requestAuthorization(
            options: authOptions
        ) { _, _ in
            self.getCurrentPushNotificationPermissionAuthorization()
        }
    }

    public func getCurrentPushNotificationPermissionAuthorization() {
        notificationEnvironmentModel.getNotificationSettings(completionHandler: { settings in
            DispatchQueue.main.async { [unowned self] in
                pushNotificationStatus = settings.authorizationStatus
            }
        })
    }

    public func initialize() {
        getCurrentPushNotificationPermissionAuthorization()
    }
}
