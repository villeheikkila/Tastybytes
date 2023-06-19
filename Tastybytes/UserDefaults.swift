import SwiftUI

enum UserDefaultsKey: String {
    case selectedTab = "selected_tab"
    case isOnboardedOnDevice = "is_current_device_onboarded"
    case colorScheme = "color_scheme"
}

extension AppStorage {
    init(wrappedValue: Value, _ key: UserDefaultsKey, store: UserDefaults? = nil) where Value == Tab {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

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
