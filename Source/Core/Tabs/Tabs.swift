import Models
import SwiftUI

public enum Tabs: Int, Identifiable, Hashable, CaseIterable, Codable, Sendable {
    case activity, discover, notifications, admin, profile

    public var id: Int {
        rawValue
    }

    @MainActor
    var tab: Tab<Tabs, some View, some View> {
        Tab(
            label,
            systemImage: systemImage,
            value: self,
            content: {
                view
            }
        )
    }

    @MainActor
    var view: some View {
        RouterProvider(enableRoutingFromURLs: true) {
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
    }

    var label: LocalizedStringKey {
        switch self {
        case .activity:
            "tab.activity"
        case .discover:
            "tab.discover"
        case .notifications:
            "tab.notifications"
        case .admin:
            "tab.admin"
        case .profile:
            "tab.profile"
        }
    }

    var systemImage: String {
        switch self {
        case .activity:
            "list.star"
        case .discover:
            "magnifyingglass"
        case .notifications:
            "bell"
        case .admin:
            "exclamationmark.lock.fill"
        case .profile:
            "person.fill"
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
    init(wrappedValue: Value, _ key: UserDefaultsKey, store: UserDefaults? = nil) where Value == Tabs {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }
}
