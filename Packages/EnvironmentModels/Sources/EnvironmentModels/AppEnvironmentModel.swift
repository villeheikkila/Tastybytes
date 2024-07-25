import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

public enum AppState: Sendable, Equatable {
    case error([Error])
    case tooOldAppVersion
    case operational
    case loading

    public static func == (lhs: AppState, rhs: AppState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.operational, .operational):
            true
        case let (.error(lhsErrors), .error(rhsErrors)):
            lhsErrors.count == rhsErrors.count && lhsErrors.elementsEqual(rhsErrors, by: { $0.localizedDescription == $1.localizedDescription })
        default:
            false
        }
    }
}

public enum SplashScreenState {
    case showing, dismissing, finished
}

enum AppDataKey: String, CaseIterable {
    case appDataCategories = "app_data_categories"
    case appDataCountries = "app_data_countries"
    case appDataFlavors = "app_data_flavors"
    case appDataAboutPage = "app_data_about_page"
    case appDataAppConfig = "app_data_app_config"
    case appDataSubscriptionGroup = "app_data_subcategories"
    case profileData = "profile_data"
    case profileDeleted = "profile_deleted"
}

extension UserDefaults {
    static func set(value: some Codable, forKey key: AppDataKey) {
        let data = try? JSONEncoder().encode(value)
        UserDefaults.standard.setValue(data, forKey: key.rawValue)
    }

    static func read<Element: Codable>(forKey key: AppDataKey) -> Element? {
        guard let data = UserDefaults.standard.data(forKey: key.rawValue) else { return nil }
        let element = try? JSONDecoder().decode(Element.self, from: data)
        return element
    }

    static func clearUserDefaults() {
        let userDefaults = UserDefaults.standard
        for key in AppDataKey.allCases {
            userDefaults.removeObject(forKey: key.rawValue)
        }
        userDefaults.synchronize()
    }
}

@MainActor
@Observable
public final class AppEnvironmentModel {
    private let logger = Logger(category: "AppEnvironmentModel")
    // App state
    public var isInitializing = false
    public var state: AppState = .loading {
        didSet {
            dismissSplashScreen()
        }
    }

    public var alertError: AlertEvent?
    // App data
    public var categories: [Models.Category.JoinedSubcategoriesServingStyles] {
        get {
            access(keyPath: \.categories)
            return UserDefaults.read(forKey: .appDataCategories) ?? []
        }

        set {
            withMutation(keyPath: \.categories) {
                UserDefaults.set(value: newValue, forKey: .appDataCategories)
            }
        }
    }

    public var appConfig: AppConfig? {
        get {
            access(keyPath: \.appConfig)
            return UserDefaults.read(forKey: .appDataAppConfig)
        }

        set {
            withMutation(keyPath: \.appConfig) {
                UserDefaults.set(value: newValue, forKey: .appDataAppConfig)
            }
        }
    }

    public var flavors: [Flavor.Saved] {
        get {
            access(keyPath: \.flavors)
            return UserDefaults.read(forKey: .appDataFlavors) ?? []
        }

        set {
            withMutation(keyPath: \.flavors) {
                UserDefaults.set(value: newValue, forKey: .appDataFlavors)
            }
        }
    }

    public var countries: [Country.Saved] {
        get {
            access(keyPath: \.countries)
            return UserDefaults.read(forKey: .appDataCountries) ?? []
        }

        set {
            withMutation(keyPath: \.countries) {
                UserDefaults.set(value: newValue, forKey: .appDataCountries)
            }
        }
    }

    public var subscriptionGroup: SubscriptionGroup.Joined? {
        get {
            access(keyPath: \.subscriptionGroup)
            return UserDefaults.read(forKey: .appDataSubscriptionGroup)
        }

        set {
            withMutation(keyPath: \.subscriptionGroup) {
                UserDefaults.set(value: newValue, forKey: .appDataSubscriptionGroup)
            }
        }
    }

    public var aboutPage: Document.About.Page? {
        get {
            access(keyPath: \.aboutPage)
            return UserDefaults.read(forKey: .appDataAboutPage)
        }

        set {
            withMutation(keyPath: \.aboutPage) {
                UserDefaults.set(value: newValue, forKey: .appDataAboutPage)
            }
        }
    }

    // Getters that are only available after initialization, calling these before authentication causes an app crash
    public var config: AppConfig {
        if let appConfig {
            appConfig
        } else {
            fatalError("Tried to access config before app environment model was initialized")
        }
    }

    // Splash screen
    public var splashScreenState: SplashScreenState = .showing
    private var splashScreenDismissalTask: Task<Void, Never>?
    // Props
    private let repository: Repository
    public let infoPlist: InfoPlist

    public init(repository: Repository, infoPlist: InfoPlist) {
        self.repository = repository
        self.infoPlist = infoPlist
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
        let startTime = DispatchTime.now()
        let isPreviouslyInitialied = aboutPage != nil && subscriptionGroup != nil && appConfig != nil && !countries.isEmpty && !flavors.isEmpty && !categories.isEmpty

        logger.notice("\(reset || isPreviouslyInitialied ? "Refreshing" : "Initializing") app data")
        if !reset, isPreviouslyInitialied, state == .loading {
            splashScreenState = .finished
            state = .operational
            logger.info("App optimistically loaded from stored data")
        }

        async let appConfigPromise = repository.appConfig.get()
        async let aboutPagePromise = repository.document.getAboutPage()
        async let flavorPromise = repository.flavor.getAll()
        async let categoryPromise = repository.category.getAllWithSubcategoriesServingStyles()
        async let countryPromise = repository.location.getAllCountries()
        async let subscriptionGroupPromise = repository.subscription.getActiveGroup()

        var errors: [Error] = []

        do {
            let appConfig = try await appConfigPromise
            self.appConfig = appConfig
            if appConfig.minimumSupportedVersion > infoPlist.appVersion {
                let config = infoPlist.appVersion.prettyString
                logger.error("App is too old to run against the latest API, app version \(config)")
                state = .tooOldAppVersion
                return
            }
        } catch {
            errors.append(error)
            logger.error("Failed to load app config. Error: \(error) (\(#file):\(#line))")
        }
        do {
            let (flavorResponse, categoryResponse, aboutPageResponse, countryResponse, subscriptionGroup) = try await (
                flavorPromise,
                categoryPromise,
                aboutPagePromise,
                countryPromise,
                subscriptionGroupPromise
            )
            self.subscriptionGroup = subscriptionGroup
            flavors = flavorResponse
            categories = categoryResponse
            aboutPage = aboutPageResponse
            countries = countryResponse
        } catch {
            errors.append(error)
        }
        guard !isPreviouslyInitialied else { return }

        withAnimation {
            state = if errors.isEmpty {
                .operational
            } else {
                .error(errors)
            }
        }
        logger.info("App \(reset ? "refreshed" : "initialized") in \(startTime.elapsedTime())ms")
    }

    // Flavors
    public func addFlavor(name: String) async {
        do {
            let newFlavor = try await repository.flavor.insert(name: name)
            withAnimation {
                flavors.append(newFlavor)
            }
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete flavor. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func deleteFlavor(_ flavor: Flavor.Saved) async {
        do {
            try await repository.flavor.delete(id: flavor.id)
            withAnimation {
                flavors.remove(object: flavor)
            }
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete flavor: '\(flavor.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func refreshFlavors() async {
        do {
            let flavors = try await repository.flavor.getAll()
            withAnimation {
                self.flavors = flavors
            }
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Fetching flavors failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    // Categories
    public func verifySubcategory(_ subcategory: SubcategoryProtocol, isVerified: Bool, onSuccess: () -> Void) async {
        do {
            try await repository.subcategory.verification(id: subcategory.id, isVerified: isVerified)
            await loadCategories()
            onSuccess()
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to \(isVerified ? "unverify" : "labels.verify") subcategory \(subcategory.id). error: \(error)")
        }
    }

    public func editSubcategory(_ updateRequest: Subcategory.UpdateRequest) async {
        do {
            try await repository.subcategory.update(updateRequest: updateRequest)
            await loadCategories()
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
        }
    }

    public func deleteSubcategory(_ deleteSubcategory: SubcategoryProtocol) async {
        do {
            try await repository.subcategory.delete(id: deleteSubcategory.id)
            await loadCategories()
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete subcategory \(deleteSubcategory.name). Error: \(error) (\(#file):\(#line))")
        }
    }

    public func addCategory(name: String) async {
        do {
            let category = try await repository.category.insert(name: name)
            categories.append(category)
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to add new category with name \(name). Error: \(error) (\(#file):\(#line))")
        }
    }

    public func addSubcategory(category: Models.Category.JoinedSubcategoriesServingStyles, name: String, onCreate: ((Subcategory.Saved) -> Void)? = nil) async {
        do {
            let newSubcategory = try await repository.subcategory
                .insert(newSubcategory: Subcategory.NewRequest(name: name, category: category))
            categories = categories.replacing(category, with: category.appending(subcategory: newSubcategory))
            if let onCreate {
                onCreate(newSubcategory)
            }
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to create subcategory '\(name)' to category \(category.name). Error: \(error) (\(#file):\(#line))")
        }
    }

    public func loadCategories() async {
        do {
            let categories = try await repository.category.getAllWithSubcategoriesServingStyles()
            self.categories = categories
        } catch {
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to load categories. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func deleteCategory(_ category: Models.Category.JoinedSubcategoriesServingStyles, onDelete: () -> Void) async {
        do {
            try await repository.category.deleteCategory(id: category.id)
            categories = categories.removing(category)
            onDelete()
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to delete category. Error: \(error) (\(#file):\(#line))")
        }
    }
}
