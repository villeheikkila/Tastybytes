import EnvironmentModels
import Models
import SwiftUI

enum UserDefaultsKey: String, CaseIterable {
    case selectedTab = "selected_tab"
    case navigationStack = "navigation_stack"
    case selectedSidebarTab = "selected_sidebar_tab"
    case isOnboardedOnDevice = "is_current_device_onboarded"
    case colorScheme = "color_scheme"
    case appDataCategories = "app_data_categories"
    case appDataCountries = "app_data_countries"
    case appDataFlavors = "app_data_flavors"
    case appDataAboutPage = "app_data_about_page"
    case appDataAppConfig = "app_data_app_config"
    case appDataSubscriptionGroup = "app_data_subcategories"
    case profileDeleted = "profile_deleted"
}

extension UserDefaults {
    func set(value: some Codable, forKey key: UserDefaultsKey) {
        let data = try? JSONEncoder().encode(value)
        UserDefaults.standard.setValue(data, forKey: key.rawValue)
    }

    func codable<Element: Codable>(forKey key: UserDefaultsKey) -> Element? {
        guard let data = UserDefaults.standard.data(forKey: key.rawValue) else { return nil }
        let element = try? JSONDecoder().decode(Element.self, from: data)
        return element
    }

    func set(value: some Codable, prefix: UserDefaultsKey, key: String) {
        let data = try? JSONEncoder().encode(value)
        UserDefaults.standard.setValue(data, forKey: "\(prefix)_\(key)")
    }

    func codable<Element: Codable>(prefix: UserDefaultsKey, key: String) -> Element? {
        guard let data = UserDefaults.standard.data(forKey: "\(prefix)_\(key)") else { return nil }
        let element = try? JSONDecoder().decode(Element.self, from: data)
        return element
    }
}

extension UserDefaults {
    func reset() {
        UserDefaultsKey.allCases.forEach { removeObject(forKey: $0.rawValue) }
    }
}

extension AppStorage {
    init(wrappedValue: Value, _ key: UserDefaultsKey, store: UserDefaults? = nil) where Value == Bool {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    init(wrappedValue: Value, _ key: UserDefaultsKey, store: UserDefaults? = nil) where Value == Int {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    init(wrappedValue: Value, _ key: UserDefaultsKey, store: UserDefaults? = nil) where Value == Double {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    init(wrappedValue: Value, _ key: UserDefaultsKey, store: UserDefaults? = nil) where Value == URL {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    init(wrappedValue: Value, _ key: UserDefaultsKey, store: UserDefaults? = nil) where Value == String {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    init(wrappedValue: Value, _ key: UserDefaultsKey, store: UserDefaults? = nil) where Value == Data {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }
}

extension UserDefaults {
    func set(_ value: Any, for key: UserDefaultsKey) {
        set(value, forKey: key.rawValue)
    }

    func removeObject(for key: UserDefaultsKey) {
        removeObject(forKey: key.rawValue)
    }

    func bool(for key: UserDefaultsKey) -> Bool {
        bool(forKey: key.rawValue)
    }

    func data(for key: UserDefaultsKey) -> Data? {
        data(forKey: key.rawValue)
    }

    func string(for key: UserDefaultsKey) -> String? {
        string(forKey: key.rawValue)
    }

    func integer(for key: UserDefaultsKey) -> Int? {
        integer(forKey: key.rawValue)
    }

    func float(for key: UserDefaultsKey) -> Float? {
        float(forKey: key.rawValue)
    }

    func url(for key: UserDefaultsKey) -> URL? {
        url(forKey: key.rawValue)
    }

    func value(for key: UserDefaultsKey) -> Any? {
        value(forKey: key.rawValue)
    }
}

enum CustomColorScheme: String, CaseIterable, Codable, Equatable, Sendable {
    case system
    case light
    case dark

    var systemColorScheme: ColorScheme? {
        switch self {
        case .light:
            .light
        case .dark:
            .dark
        case .system:
            nil
        }
    }
}
