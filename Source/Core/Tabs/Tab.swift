import Models
import SwiftUI

public enum Tab: Int, Identifiable, Hashable, CaseIterable, Codable, Sendable {
    case activity, discover, notifications, admin, profile

    public var id: Int {
        rawValue
    }

    @MainActor
    @ViewBuilder
    var view: some View {
        switch self {
        case .activity:
            ActivityScreen()
        case .discover:
            DiscoverScreen()
        case .notifications:
            NotificationScreen()
        case .admin:
            AdminScreen()
        case .profile:
            CurrentProfileScreen()
        }
    }

    @ViewBuilder var label: some View {
        switch self {
        case .activity:
            Label("tab.activity", systemImage: "list.star")
        case .discover:
            Label("tab.discover", systemImage: "magnifyingglass")
        case .notifications:
            Label("tab.notifications", systemImage: "bell")
        case .admin:
            Label("tab.admin", systemImage: "exclamationmark.lock.fill")
        case .profile:
            Label("tab.profile", systemImage: "person.fill")
        }
    }

    var identifier: String {
        switch self {
        case .activity:
            "activity"
        case .discover:
            "discover"
        case .notifications:
            "notifications"
        case .admin:
            "admin"
        case .profile:
            "profile"
        }
    }
}

extension AppStorage {
    init(wrappedValue: Value, _ key: UserDefaultsKey, store: UserDefaults? = nil) where Value == Tab {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }
}
