import Logging
import Models
import Repositories
import SwiftUI

@main
struct MainApp: App {
    private let logger = Logger(label: "MainApp")
    @Environment(\.scenePhase) private var phase
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let infoPlist: InfoPlist
    private let repository: Repository
    private let logManager: LogManager

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
        let repository: Repository = .init(
            apiUrl: infoPlist.supabaseUrl,
            apiKey: infoPlist.supabaseAnonKey,
            headers: ["x_bundle_id": bundleIdentifier, "x_app_version": infoPlist.appVersion.prettyString]
        )
        let logManager = try! LogManager(onLogsSent: { entries in
            print("entries: \(entries)")
        }, internalLog: { log in print(log) })
        LoggingSystem.bootstrap { label in
            CustomLogHandler(
                label: label,
                onLogged: { entry in Task { await logManager.log(entry) }
                }
            )
        }
        self.repository = repository
        self.logManager = logManager
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
                                        NotificationObserver {
                                            TabsView()
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
        .onChange(of: phase) { _, newPhase in
            switch newPhase {
            case .active:
                Task {
                    await logManager.resumeSyncing()
                }
            case .background:
                Task {
                    await logManager.pauseSyncing()
                    try? await logManager.storeToDisk()
                }
            default:
                ()
            }
        }
    }
}
