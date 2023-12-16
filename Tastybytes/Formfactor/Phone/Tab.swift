import Models
import SwiftUI

public enum Tab: Int, Identifiable, Hashable, CaseIterable, Codable {
    case activity, discover, notifications, admin, profile

    public var id: Int {
        rawValue
    }

    public var cachesPath: String {
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

    public var cachesDirectoryPath: URL {
        URL.cachesDirectory.appending(path: cachesPath)
    }

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
            Label("Activity", systemImage: "list.star")
        case .discover:
            Label("Discover", systemImage: "magnifyingglass")
        case .notifications:
            Label("Notifications", systemImage: "bell")
        case .admin:
            Label("Admin", systemImage: "exclamationmark.lock.fill")
        case .profile:
            Label("Profile", systemImage: "person.fill")
        }
    }
}
