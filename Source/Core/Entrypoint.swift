import Logging
import Models
import Repositories
import SwiftUI
import TipKit

@main
struct Entrypoint: App {
    private let logger = Logger(label: "Entrypoint")
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var snackController: SnackController
    @State private var adminModel: AdminModel
    @State private var profileModel: ProfileModel
    @State private var appModel: AppModel
    @State private var locationModel = LocationModel()
    @State private var feedbackModel = FeedbackModel()
    @State private var checkInModel: CheckInModel
    private let repository: Repository

    init() {
        setupURLCache()
        setupDebugConfiguration(logger: logger)
        let fileManager = FileManager.default
        let applicationSupport = try! fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let (infoPlist, bundleIdentifier, isDebug) = readEnvironment()
        let repository = makeRepository(infoPlist: infoPlist, bundleIdentifier: bundleIdentifier)
        let snackController = SnackController()
        let profileStorage = DiskStorage<Profile.Populated>(fileManager: fileManager, filename: "profile_data.json")
        let appStorage = DiskStorage<AppData>(fileManager: fileManager, filename: "app_data.json")
        let appModel = AppModel(repository: repository, storage: appStorage, infoPlist: infoPlist, onSnack: snackController.open)
        checkInModel = CheckInModel(
            repository: repository,
            onSnack: snackController.open,
            storeAt: applicationSupport,
            pageSize: appModel.rateControl
                .checkInPageSize,
            loadMoreThreshold: appModel.rateControl
                .loadMoreThreshold
        )
        adminModel = AdminModel(repository: repository, onSnack: snackController.open)
        profileModel = ProfileModel(repository: repository, isDebug: isDebug, storage: profileStorage, onSnack: snackController.open)
        self.snackController = snackController
        self.repository = repository
        self.appModel = appModel
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
        .environment(locationModel)
        .environment(feedbackModel)
        .environment(snackController)
        .environment(checkInModel)
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

func readEnvironment() -> (InfoPlist, String, Bool) {
    #if DEBUG
        let isDebug = true
    #else
        let isDebug = false
    #endif
    guard let infoDictionary = Bundle.main.infoDictionary,
          let bundleIdentifier = Bundle.main.bundleIdentifier,
          let jsonData = try? JSONSerialization.data(withJSONObject: infoDictionary, options: .prettyPrinted),
          let infoPlist = try? JSONDecoder().decode(InfoPlist.self, from: jsonData)
    else {
        fatalError("Failed to decode required data for main app")
    }
    return (infoPlist, bundleIdentifier, isDebug)
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
