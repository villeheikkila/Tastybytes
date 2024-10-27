import Logging
import Models
import Repositories
import SwiftUI

@main
struct MainApp: App {
    private let logger = Logger(label: "MainApp")
    @Environment(\.scenePhase) private var phase
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var logManagerContainer = LogManagerContainer()
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
        self.repository = Repository(
            apiUrl: infoPlist.supabaseUrl,
            apiKey: infoPlist.supabaseAnonKey,
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
            .task {
                await initializeLogging()
            }
        }
        .environment(repository)
        .onChange(of: phase) { _, newPhase in
            switch newPhase {
            case .active:
                Task {
                    await logManagerContainer.logManager?.resumeSyncing()
                }
            case .background:
                Task {
                    await logManagerContainer.logManager?.pauseSyncing()
                    try? await logManagerContainer.logManager?.storeToDisk()
                }
            default:
                ()
            }
        }
    }
    
    private func initializeLogging() async {
        do {
            let cache = try await SimpleCache<LogEntry>(fileName: "logs.json")
            let cachedLogManager = try CachedLogManager(cache: cache, onLogsSent: { entries in
                print("entries: \(entries)")
            }, internalLog: { log in print(log) })
            let bundleIdentifier = Bundle.main.bundleIdentifier!
            let osLogManager = OSLogManager(subsystem: bundleIdentifier)
            #if DEBUG
                let customLogHandlerManager = osLogManager
            #else
                let customLogHandlerManager = cachedLogManager
            #endif
            LoggingSystem.bootstrap { label in
                CustomLogHandler(
                    label: label,
                    logManager: customLogHandlerManager
                )
            }
            logManagerContainer.logManager = cachedLogManager
        } catch {
            logger.error("Failed to initialize logging: \(error)")
        }
    }
}

@Observable
class LogManagerContainer {
    var logManager: CachedLogManager?
}
