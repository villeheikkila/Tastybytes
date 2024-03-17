import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

@main
struct MainApp: App {
    private let logger = Logger(category: "MainApp")
    #if !os(watchOS)
        @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    private let infoPlist: InfoPlist
    private let repository: Repository

    init() {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let bundleIdentifier = Bundle.main.bundleIdentifier,
              let jsonData = try? JSONSerialization.data(withJSONObject: infoDictionary, options: .prettyPrinted),
              let infoPlist = try? JSONDecoder().decode(InfoPlist.self, from: jsonData)
        else {
            fatalError("Failed to decode required data for main app")
        }

        self.infoPlist = infoPlist
        repository = .init(
            supabaseURL: infoPlist.supabaseUrl,
            supabaseKey: infoPlist.supabaseAnonKey,
            headers: ["x_bundle_id": bundleIdentifier, "x_app_version": infoPlist.appVersion.prettyString]
        )
    }

    var body: some Scene {
        WindowGroup {
            EnvironmentProvider(repository: repository, infoPlist: infoPlist) {
                DeviceInfoProvider {
                    SplashScreenProvider {
                        PhaseObserver {
                            AppStateObserver {
                                SubscriptionProvider {
                                    AuthStateObserver {
                                        ProfileStateObserver {
                                            IdiomSelector()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .environment(repository)
    }
}
