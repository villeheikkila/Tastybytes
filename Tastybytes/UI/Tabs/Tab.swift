import Models
import SwiftUI

public enum Tab: Int, Identifiable, Hashable, CaseIterable {
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
    func view(selectedTab: Binding<Tab>, _ resetNavigationOnTab: Binding<Tab?>) -> some View {
        switch self {
        case .activity:
            ActivityTab(resetNavigationOnTab: resetNavigationOnTab, selectedTab: selectedTab)
        case .discover:
            DiscoverTab(resetNavigationOnTab: resetNavigationOnTab)
        case .notifications:
            NotificationTab(resetNavigationOnTab: resetNavigationOnTab)
        case .admin:
            AdminTab(resetNavigationOnTab: resetNavigationOnTab)
        case .profile:
            ProfileTab(resetNavigationOnTab: resetNavigationOnTab)
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
