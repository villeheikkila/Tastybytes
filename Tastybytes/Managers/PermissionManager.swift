import AVFoundation
import Observation
import OSLog
import PhotosUI
import SwiftUI

@Observable
final class PermissionManager {
    private let logger = Logger(category: "PermissionManager")
    private let locationManager = CLLocationManager()
    private let notificationManager = UNUserNotificationCenter.current()

    var pushNotificationStatus: UNAuthorizationStatus = .notDetermined
    var cameraStatus: AVAuthorizationStatus = .notDetermined
    var photoLibraryStatus: PHAuthorizationStatus = .notDetermined
    var locationsStatus: CLAuthorizationStatus = .notDetermined

    // push notifications
    func requestPushNotificationAuthorization() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        notificationManager.requestAuthorization(
            options: authOptions
        ) { _, _ in
            self.getCurrentPushNotificationPermissionAuthorization()
        }
    }

    func getCurrentPushNotificationPermissionAuthorization() {
        notificationManager.getNotificationSettings(completionHandler: { settings in
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
        locationsStatus = locationManager.authorizationStatus
    }

    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func initialize() {
        getCurrentPushNotificationPermissionAuthorization()
        getCurrentCameraPermissionAuthorization()
        getCurrentPhotoLibraryAuthorization()
        getCurrentLocationAuthorization()
    }
}
