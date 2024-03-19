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
            ActivityTab()
        case .discover:
            DiscoverTab()
        case .notifications:
            NotificationTab()
        case .admin:
            AdminTab()
        case .profile:
            ProfileTab()
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
}

extension AppStorage {
    init(wrappedValue: Value, _ key: UserDefaultsKey, store: UserDefaults? = nil) where Value == Tab {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }
}
