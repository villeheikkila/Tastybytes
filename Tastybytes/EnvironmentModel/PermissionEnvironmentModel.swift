import AVFoundation
import Observation
import OSLog
import PhotosUI
import SwiftUI

@Observable
final class PermissionEnvironmentModel {
    private let logger = Logger(category: "PermissionEnvironmentModel")
    private let locationEnvironmentModel = CLLocationManager()
    private let notificationEnvironmentModel = UNUserNotificationCenter.current()

    var pushNotificationStatus: UNAuthorizationStatus = .notDetermined
    var cameraStatus: AVAuthorizationStatus = .notDetermined
    var photoLibraryStatus: PHAuthorizationStatus = .notDetermined
    var locationsStatus: CLAuthorizationStatus = .notDetermined

    // push notifications
    func requestPushNotificationAuthorization() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        notificationEnvironmentModel.requestAuthorization(
            options: authOptions
        ) { _, _ in
            self.getCurrentPushNotificationPermissionAuthorization()
        }
    }

    func getCurrentPushNotificationPermissionAuthorization() {
        notificationEnvironmentModel.getNotificationSettings(completionHandler: { settings in
            DispatchQueue.main.async { [unowned self] in
                pushNotificationStatus = settings.authorizationStatus
            }
        })
    }

    // camera
    func requestCameraAuthorization() {
        AVCaptureDevice.requestAccess(for: .video) { _ in
            DispatchQueue.main.async {
                self.cameraStatus = .authorized
            }
        }
    }

    func getCurrentCameraPermissionAuthorization() {
        cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }

    // photo library
    func getCurrentPhotoLibraryAuthorization() {
        photoLibraryStatus = PHPhotoLibrary.authorizationStatus()
    }

    func requestPhotoLibraryAuthorization() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                self.photoLibraryStatus = status
            }
        }
    }

    // location
    func getCurrentLocationAuthorization() {
        locationsStatus = locationEnvironmentModel.authorizationStatus
    }

    func requestLocationAuthorization() {
        locationEnvironmentModel.requestWhenInUseAuthorization()
    }

    func initialize() {
        getCurrentPushNotificationPermissionAuthorization()
        getCurrentCameraPermissionAuthorization()
        getCurrentPhotoLibraryAuthorization()
        getCurrentLocationAuthorization()
    }
}
