import SwiftUI

@MainActor
struct WatchView: View {
    @State private var selection: WatchTab = .activity

    var body: some View {
        TabView(selection: $selection) {
            tabs
        }
    }

    private var tabs: some View {
        ForEach(WatchTab.allCases) { tab in
            tab.view
                .tabItem {
                    tab.label
                }
                .tag(tab)
        }
    }
}

public enum WatchTab: Int, Identifiable, Hashable, CaseIterable, Codable, Sendable {
    case activity, notifications, profile

    public var id: Int {
        rawValue
    }

    @MainActor
    @ViewBuilder
    var view: some View {
        NavigationStack {
            switch self {
            case .activity:
                ActivityWatchTab()
            case .notifications:
                Text("tab.notifications")
            case .profile:
                Text("tab.profile")
            }
        }
    }

    @ViewBuilder var label: some View {
        switch self {
        case .activity:
            Label("tab.activity", systemImage: "list.star")
        case .notifications:
            Label("tab.notifications", systemImage: "bell")
        case .profile:
            Label("tab.profile", systemImage: "person.fill")
        }
    }
}
