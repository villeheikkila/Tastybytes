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
