import Extensions
import Logging
import Models
import Repositories
import SwiftUI

enum AppState: Sendable, Equatable {
    case error(Error)
    case tooOldAppVersion
    case operational(AppData)
    case loading
    case underMaintenance

    var isOperational: Bool {
        if case .operational = self {
            return true
        }
        return false
    }

    static func == (lhs: AppState, rhs: AppState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            true
        case (.tooOldAppVersion, .tooOldAppVersion):
            true
        case (.underMaintenance, .underMaintenance):
            true
        case let (.operational(lhsData), .operational(rhsData)):
            lhsData == rhsData
        case let (.error(lhsErrors), .error(rhsErrors)):
            lhsErrors.localizedDescription == rhsErrors.localizedDescription
        default:
            false
        }
    }
}

struct AppData: Codable, Hashable {
    let categories: [Models.Category.JoinedSubcategoriesServingStyles]
    let appConfig: AppConfig
    let flavors: [Flavor.Saved]
    let countries: [Country.Saved]
    let subscriptionGroup: SubscriptionGroup.Joined?
    let aboutPage: Document.About.Page?
    // meta
    let version: Int

    init(
        categories: [Models.Category.JoinedSubcategoriesServingStyles],
        appConfig: AppConfig,
        flavors: [Flavor.Saved],
        countries: [Country.Saved],
        subscriptionGroup: SubscriptionGroup.Joined?,
        aboutPage: Document.About.Page?,
        version: Int
    ) {
        self.categories = categories
        self.appConfig = appConfig
        self.flavors = flavors
        self.countries = countries
        self.subscriptionGroup = subscriptionGroup
        self.aboutPage = aboutPage
        self.version = version
    }

    func copyWith(
        categories: [Models.Category.JoinedSubcategoriesServingStyles]? = nil,
        appConfig: AppConfig? = nil,
        flavors: [Flavor.Saved]? = nil,
        countries: [Country.Saved]? = nil,
        subscriptionGroup: SubscriptionGroup.Joined? = nil,
        aboutPage: Document.About.Page? = nil
    ) -> AppData {
        .init(
            categories: categories ?? self.categories,
            appConfig: appConfig ?? self.appConfig,
            flavors: flavors ?? self.flavors,
            countries: countries ?? self.countries,
            subscriptionGroup: subscriptionGroup ?? self.subscriptionGroup,
            aboutPage: aboutPage ?? self.aboutPage,
            version: version
        )
    }
}

struct RateControl: Sendable {
    let checkInPageSize = 10
    let checkInImagePageSize = 10
    let productFeedPageSize = 50
    let loadMoreThreshold = 8
}

struct IncludedLibrary: Identifiable, Hashable, Sendable {
    let name: String
    let link: URL

    var id: Int {
        hashValue
    }
}

enum AppDataKey: String, CaseIterable {
    case deviceToken = "device_token"
    case profileDeleted = "profile_deleted"
}

@MainActor
@Observable
final class AppModel {
    private let logger = Logger(label: "AppModel")
    private let dataVersion = 1
    // app state
    var isInitializing = false
    var state: AppState = .loading {
        didSet {
            if case let .operational(appData) = state {
                try? storage.save(appData)
            }
        }
    }

    // app data
    var categories: [Models.Category.JoinedSubcategoriesServingStyles] {
        if case let .operational(appData) = state {
            return appData.categories
        }
        return []
    }

    var appConfig: AppConfig? {
        if case let .operational(appData) = state {
            return appData.appConfig
        }
        return nil
    }

    var flavors: [Flavor.Saved] {
        if case let .operational(appData) = state {
            return appData.flavors
        }
        return []
    }

    var countries: [Country.Saved] {
        if case let .operational(appData) = state {
            return appData.countries
        }
        return []
    }

    var subscriptionGroup: SubscriptionGroup.Joined? {
        if case let .operational(appData) = state {
            return appData.subscriptionGroup
        }
        return nil
    }

    var aboutPage: Document.About.Page? {
        if case let .operational(appData) = state {
            return appData.aboutPage
        }
        return nil
    }

    // Getters that are only available after initialization, calling these before authentication causes an app crash
    var config: AppConfig {
        if let appConfig {
            appConfig
        } else {
            fatalError("Tried to access config before app environment model was initialized")
        }
    }

    // Props
    private let repository: Repository
    private let storage: any StorageProtocol<AppData>
    private let onSnack: OnSnack
    let infoPlist: InfoPlist

    let rateControl = RateControl()

    let includedLibraries: [IncludedLibrary] = [
        .init(name: "supabase-swift", link: .init(string: "https://github.com/supabase/supabase-swift")!),
        .init(name: "swift-tagged", link: .init(string: "https://github.com/pointfreeco/swift-tagged")!),
        .init(name: "Brightroom", link: .init(string: "https://github.com/FluidGroup/Brightroom")!),
        .init(name: "BlurHashViews", link: .init(string: "https://github.com/daprice/BlurHashViews")!),
    ]

    init(
        repository: Repository,
        storage: any StorageProtocol<AppData>,
        infoPlist: InfoPlist,
        onSnack: @escaping OnSnack
    ) {
        self.repository = repository
        self.storage = storage
        self.infoPlist = infoPlist
        self.onSnack = onSnack
    }

    public func initialize(cache: Bool = false) async {
        defer { isInitializing = false }
        guard !isInitializing else { return }
        isInitializing = true
        let startTime = DispatchTime.now()
        if !cache, let cachedData = try? storage.load(), cachedData.version == dataVersion {
            state = .operational(cachedData)
            logger.info("App optimistically loaded from stored data, refreshing...")
        }
        async let appConfigPromise = repository.appConfig.get()
        async let aboutPagePromise = repository.document.getAboutPage()
        async let flavorPromise = repository.flavor.getAll()
        async let categoryPromise = repository.category.getAllWithSubcategoriesServingStyles()
        async let countryPromise = repository.location.getAllCountries()
        async let subscriptionGroupPromise = repository.subscription.getActiveGroup()
        let aConfig: AppConfig?
        do {
            let appConfig = try await appConfigPromise
            if appConfig.isUnderMaintenance {
                state = .underMaintenance
                return
            } else if appConfig.minimumSupportedVersion > infoPlist.appVersion {
                let config = infoPlist.appVersion.prettyString
                logger.error("App is too old to run against the latest API, app version \(config)")
                state = .tooOldAppVersion
                return
            }
            aConfig = appConfig
        } catch {
            if error.isNetworkUnavailable, state.isOperational {
                return
            }
            state = .error(error)
            logger.error("Failed to load app config. Error: \(error) (\(#file):\(#line))")
            return
        }
        do {
            let (flavorResponse, categoryResponse, aboutPageResponse, countryResponse, subscriptionGroup) = try await (
                flavorPromise,
                categoryPromise,
                aboutPagePromise,
                countryPromise,
                subscriptionGroupPromise
            )
            logger.info("App \(state.isOperational ? "refreshed" : "initialized") in \(startTime.elapsedTime())ms")
            state = .operational(.init(categories: categoryResponse, appConfig: aConfig!, flavors: flavorResponse, countries: countryResponse, subscriptionGroup: subscriptionGroup, aboutPage: aboutPageResponse, version: dataVersion))
        } catch {
            if error.isNetworkUnavailable, state.isOperational {
                return
            }
            logger.error("Failed to load app data. Error: \(error) (\(#file):\(#line))")
            state = .error(error)
        }
    }

    // Flavors
    func addFlavor(name: String) async {
        do {
            let newFlavor = try await repository.flavor.insert(name: name)
            guard case let .operational(appData) = state else { return }

            withAnimation {
                state = .operational(appData.copyWith(flavors: appData.flavors + [newFlavor]))
            }
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Failed to add flavor")))
            logger.error("Failed to delete flavor. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteFlavor(_ flavor: Flavor.Saved) async {
        guard case let .operational(appData) = state else { return }
        do {
            try await repository.flavor.delete(id: flavor.id)
            withAnimation {
                state = .operational(appData.copyWith(flavors: appData.flavors.filter { $0 != flavor }))
            }
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Failed to delete flavor")))
            logger.error("Failed to delete flavor: '\(flavor.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func refreshFlavors() async {
        guard case let .operational(appData) = state else { return }
        do {
            let flavors = try await repository.flavor.getAll()
            withAnimation {
                state = .operational(appData.copyWith(flavors: flavors))
            }
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Failed to refresh flavors")))
            logger.error("Fetching flavors failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    // Categories
    func verifySubcategory(_ subcategory: SubcategoryProtocol, isVerified: Bool, onSuccess: () -> Void) async {
        do {
            try await repository.subcategory.verification(id: subcategory.id, isVerified: isVerified)
            await loadCategories()
            onSuccess()
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Failed to \(isVerified ? "unverify" : "labels.verify") subcategory")))
            logger.error("Failed to \(isVerified ? "unverify" : "labels.verify") subcategory \(subcategory.id). error: \(error)")
        }
    }

    func editSubcategory(_ updateRequest: Subcategory.UpdateRequest) async {
        do {
            try await repository.subcategory.update(updateRequest: updateRequest)
            await loadCategories()
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Failed to edit subcategory")))
        }
    }

    func deleteSubcategory(_ deleteSubcategory: SubcategoryProtocol) async {
        do {
            try await repository.subcategory.delete(id: deleteSubcategory.id)
            await loadCategories()
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Failed to delete subcategory")))
            logger.error("Failed to delete subcategory \(deleteSubcategory.name). Error: \(error) (\(#file):\(#line))")
        }
    }

    func addCategory(name: String) async {
        guard case let .operational(appData) = state else { return }
        do {
            let category = try await repository.category.insert(name: name)
            state = .operational(appData.copyWith(categories: appData.categories + [category]))
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Failed to add category")))
            logger.error("Failed to add new category with name \(name). Error: \(error) (\(#file):\(#line))")
        }
    }

    func addSubcategory(category: Models.Category.JoinedSubcategoriesServingStyles, name: String, onCreate: ((Subcategory.Saved) -> Void)? = nil) async {
        guard case let .operational(appData) = state else { return }
        do {
            let newSubcategory = try await repository.subcategory
                .insert(newSubcategory: Subcategory.NewRequest(name: name, category: category))
            state = .operational(appData.copyWith(categories: categories.replacing(category, with: category.appending(subcategory: newSubcategory))))
            if let onCreate {
                onCreate(newSubcategory)
            }
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Failed to create subcategory")))
            logger.error("Failed to create subcategory '\(name)' to category \(category.name). Error: \(error) (\(#file):\(#line))")
        }
    }

    func loadCategories() async {
        guard case let .operational(appData) = state else { return }
        do {
            let categories = try await repository.category.getAllWithSubcategoriesServingStyles()
            state = .operational(appData.copyWith(categories: categories))
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Failed to load categories")))
            logger.error("Failed to load categories. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteCategory(_ category: Models.Category.JoinedSubcategoriesServingStyles, onDelete: () -> Void) async {
        guard case let .operational(appData) = state else { return }
        do {
            try await repository.category.deleteCategory(id: category.id)
            state = .operational(appData.copyWith(categories: categories.removing(category)))
            onDelete()
        } catch {
            guard !error.isCancelled else { return }
            onSnack(.init(mode: .snack(tint: .red, systemName: "exclamationmark.triangle.fill", message: "Failed to delete category")))
            logger.error("Failed to delete category. Error: \(error) (\(#file):\(#line))")
        }
    }
}
