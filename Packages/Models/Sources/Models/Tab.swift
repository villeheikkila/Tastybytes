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
}
