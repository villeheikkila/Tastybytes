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
        #if DEBUG
            if Bundle(path: "/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework")?.load() != true {
                logger.error("Failed to load linker framework")
            } else {
                logger.info("RocketSim Connect succesfully linked")
            }
        #endif

        URLCache.shared.memoryCapacity = 50_000_000 // 50M
        URLCache.shared.diskCapacity = 200_000_000 // 200MB

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
                SplashScreenProvider {
                    PhaseObserver {
                        AppStateObserver {
                            SubscriptionProvider {
                                AuthStateObserver {
                                    ProfileStateObserver {
                                        #if !os(watchOS)
                                            OnboardingStateObserver {
                                                NotificationObserver {
                                                    TabsView()
                                                }
                                            }
                                        #else
                                            WatchView()
                                        #endif
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
