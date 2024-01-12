import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

public enum AppState: String, Sendable {
    case networkUnavailable
    case unexpectedError
    case tooOldAppVersion
    case operational
    case uninitialized
}

public enum SplashScreenState {
    case showing, dismissing, finished
}

@MainActor
@Observable
public final class AppEnvironmentModel {
    private let logger = Logger(category: "AppEnvironmentModel")
    // App state
    public var isInitializing = false
    public var state: AppState = .uninitialized {
        didSet {
            dismissSplashScreen()
        }
    }

    public var alertError: AlertError?
    // App data
    public var categories = [Models.Category.JoinedSubcategoriesServingStyles]()
    public var flavors = [Flavor]()
    public var countries = [Country]()
    public var aboutPage: AboutPage?
    public var appConfig: AppConfig?

    public var config: AppConfig {
        if let appConfig {
            appConfig
        } else {
            fatalError("Tried to access app config before app environment model was initialized")
        }
    }

    // Splash screen
    public var splashScreenState: SplashScreenState = .showing
    private var splashScreenDismissalTask: Task<Void, Never>?
    // Props
    private let repository: Repository
    public let infoPlist: InfoPlist

    public init(repository: Repository, configuration: InfoPlist) {
        self.repository = repository
        infoPlist = configuration
    }

    public func dismissSplashScreen() {
        guard splashScreenState == .showing, splashScreenDismissalTask == nil else { return }
        splashScreenDismissalTask = Task {
            defer { splashScreenDismissalTask = nil }
            logger.info("Dismissing splash screen")
            splashScreenState = .dismissing
            try? await Task.sleep(for: Duration.seconds(0.5))
            splashScreenState = .finished
        }
    }

    public func initialize(reset: Bool = false) async {
        defer { isInitializing = false }
        guard !isInitializing else { return }
        logger.notice("\(reset ? "Refreshing" : "Initializing") app data")
        isInitializing = true
        let startTime = DispatchTime.now()
        async let appConfigPromise = repository.appConfig.get()
        async let aboutPagePromise = repository.document.getAboutPage()
        async let flavorPromise = repository.flavor.getAll()
        async let categoryPromise = repository.category.getAllWithSubcategoriesServingStyles()
        async let countryPromise = repository.location.getAllCountries()

        let (appConfigResponse, flavorResponse, categoryResponse, aboutPageResponse, countryResponse) = await (
            appConfigPromise,
            flavorPromise,
            categoryPromise,
            aboutPagePromise,
            countryPromise
        )

        var errors: [Error] = []
        switch appConfigResponse {
        case let .success(appConfig):
            self.appConfig = appConfig
            if appConfig.minimumSupportedVersion > infoPlist.appVersion {
                let config = infoPlist.appVersion.prettyString
                logger.error("App is too old to run against the latest API, app version \(config)")
                state = .tooOldAppVersion
                return
            }
        case let .failure(error):
            errors.append(error)
            logger.error("Failed to load app config. Error: \(error) (\(#file):\(#line))")
        }
        switch flavorResponse {
        case let .success(flavors):
            self.flavors = flavors
        case let .failure(error):
            errors.append(error)
            logger.error("Failed to load flavors. Error: \(error) (\(#file):\(#line))")
        }
        switch categoryResponse {
        case let .success(categories):
            self.categories = categories
        case let .failure(error):
            errors.append(error)
            logger.error("Failed to load categories. Error: \(error) (\(#file):\(#line))")
        }
        switch aboutPageResponse {
        case let .success(aboutPage):
            self.aboutPage = aboutPage
        case let .failure(error):
            errors.append(error)
            logger.error("Failed to load about page data. Error: \(error) (\(#file):\(#line))")
        }
        switch countryResponse {
        case let .success(countries):
            self.countries = countries
        case let .failure(error):
            errors.append(error)
            logger.error("Failed to load countries. Error: \(error) (\(#file):\(#line))")
        }

        if !errors.isEmpty {
            state = errors.contains(where: { error in error.isNetworkUnavailable }) ? .networkUnavailable : .unexpectedError
            return
        }
        state = .operational
        logger.info("App \(reset ? "refreshed" : "initialized") in \(startTime.elapsedTime())ms")
    }

    // Flavors
    public func addFlavor(name: String) async {
        switch await repository.flavor.insert(newFlavor: Flavor.NewRequest(name: name)) {
        case let .success(newFlavor):
            withAnimation {
                flavors.append(newFlavor)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete flavor. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func deleteFlavor(_ flavor: Flavor) async {
        switch await repository.flavor.delete(id: flavor.id) {
        case .success:
            withAnimation {
                flavors.remove(object: flavor)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete flavor: '\(flavor.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func refreshFlavors() async {
        switch await repository.flavor.getAll() {
        case let .success(flavors):
            withAnimation {
                self.flavors = flavors
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Fetching flavors failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    // Categories
    public func verifySubcategory(_ subcategory: Subcategory, isVerified: Bool) async {
        switch await repository.subcategory.verification(id: subcategory.id, isVerified: isVerified) {
        case .success:
            await loadCategories()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger
                .error(
                    "Failed to \(isVerified ? "unverify" : "verify") subcategory \(subcategory.id). error: \(error)"
                )
        }
    }

    public func deleteSubcategory(_ deleteSubcategory: SubcategoryProtocol) async {
        switch await repository.subcategory.delete(id: deleteSubcategory.id) {
        case .success:
            await loadCategories()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete subcategory \(deleteSubcategory.name). Error: \(error) (\(#file):\(#line))")
        }
    }

    public func addCategory(name: String) async {
        switch await repository.category.insert(newCategory: Models.Category.NewRequest(name: name)) {
        case .success:
            await loadCategories()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to add new category with name \(name). Error: \(error) (\(#file):\(#line))")
        }
    }

    public func addSubcategory(category: Models.Category.JoinedSubcategoriesServingStyles, name: String) async {
        switch await repository.subcategory
            .insert(newSubcategory: Subcategory.NewRequest(name: name, category: category))
        {
        case let .success(newSubcategory):
            let updatedCategory = category.appending(subcategory: newSubcategory)
            categories.replace(category, with: updatedCategory)
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger
                .error(
                    "Failed to create subcategory '\(name)' to category \(category.name). Error: \(error) (\(#file):\(#line))"
                )
        }
    }

    public func loadCategories() async {
        switch await repository.category.getAllWithSubcategoriesServingStyles() {
        case let .success(categories):
            self.categories = categories
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to load categories. Error: \(error) (\(#file):\(#line))")
        }
    }
}
