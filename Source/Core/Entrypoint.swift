import Logging
import Models
import Repositories
import SwiftUI
import TipKit

@main
struct Entrypoint: App {
    private let logger = Logger(label: "Entrypoint")
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var logManagerContainer = LogManagerContainer()
    @State private var snackController: SnackController
    @State private var adminModel: AdminModel
    @State private var profileModel: ProfileModel
    @State private var appModel: AppModel
    @State private var checkInUploadModel: CheckInUploadModel
    @State private var locationModel = LocationModel()
    @State private var feedbackModel = FeedbackModel()
    private let repository: Repository

    init() {
        setupURLCache()
        setupDebugConfiguration(logger: logger)
        let (infoPlist, bundleIdentifier) = readEnvironment()
        let repository = makeRepository(infoPlist: infoPlist, bundleIdentifier: bundleIdentifier)
        let snackController = SnackController()
        adminModel = AdminModel(repository: repository, onSnack: snackController.open)
        profileModel = ProfileModel(
            repository: repository,
            storage: DiskStorage<Profile.Populated>(filename: "profile_data.json"),
            onSnack: snackController.open
        )
        appModel = AppModel(repository: repository, storage: DiskStorage<AppData>(filename: "app_data.json"), infoPlist: infoPlist, onSnack: snackController.open)
        checkInUploadModel = CheckInUploadModel(repository: repository, onSnack: snackController.open)
        self.snackController = snackController
        self.repository = repository
    }

    var body: some Scene {
        WindowGroup {
            ApplicationStateObserver {
                TabsView()
            }
        }
        .environment(repository)
        .environment(adminModel)
        .environment(profileModel)
        .environment(appModel)
        .environment(checkInUploadModel)
        .environment(locationModel)
        .environment(feedbackModel)
        .environment(snackController)
    }
}

@Observable
class LogManagerContainer {
    var logManager: CachedLogManager?
}

func setupURLCache() {
    URLCache.shared.memoryCapacity = 50_000_000 // 50M
    URLCache.shared.diskCapacity = 200_000_000 // 200MB
}

func setupDebugConfiguration(logger: Logger) {
    #if DEBUG
        if Bundle(path: "/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework")?.load() != true {
            logger.error("Failed to load linker framework")
        } else {
            logger.info("RocketSim Connect succesfully linked")
        }
    #endif
}

func readEnvironment() -> (InfoPlist, String) {
    guard let infoDictionary = Bundle.main.infoDictionary,
          let bundleIdentifier = Bundle.main.bundleIdentifier,
          let jsonData = try? JSONSerialization.data(withJSONObject: infoDictionary, options: .prettyPrinted),
          let infoPlist = try? JSONDecoder().decode(InfoPlist.self, from: jsonData)
    else {
        fatalError("Failed to decode required data for main app")
    }
    return (infoPlist, bundleIdentifier)
}

func makeRepository(infoPlist: InfoPlist, bundleIdentifier: String) -> Repository {
    Repository(
        apiUrl: infoPlist.supabaseUrl,
        apiKey: infoPlist.supabaseAnonKey,
        headers: ["x_bundle_id": bundleIdentifier, "x_app_version": infoPlist.appVersion.prettyString]
    )
}

func initializeLogging(logger: Logger) async {
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
    } catch {
        logger.error("Failed to initialize logging: \(error)")
    }
}
