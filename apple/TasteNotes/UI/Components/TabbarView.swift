import SwiftUI

struct TabbarView: View {
    let profile: Profile
    @EnvironmentObject var notificationManager: NotificationManager
    @State var selection = Tab.activity
    @State var showBarcodeScanner: Bool = false


    var body: some View {
        TabView(selection: $selection) {
            ActivityScreenView(profile: profile)
                .tabItem {
                    Image(systemName: "list.star")
                    Text("Activity")
                }
                .tag(Tab.activity)
            SearchScreenView(showBarcodeScanner: $showBarcodeScanner)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(Tab.search)
            NotificationScreenView()
                .tabItem {
                    Image(systemName: "bell")
                    Text("Notifications")
                }
                .badge(notificationManager
                    .notifications
                    .filter { $0.seenAt == nil }
                    .count
                )
                .tag(Tab.notifications)
            ProfileScreenView(profile: profile)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(Tab.profile)
        }
        .navigationTitle(selection.title)
        .toolbar {
            if selection == Tab.profile {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    NavigationLink(value: Route.currentUserFriends) {
                        Image(systemName: "person.2").imageScale(.large)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink(value: Route.settings) {
                        Image(systemName: "gear").imageScale(.large)
                    }
                }
            }
            
            if selection == Tab.search {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        showBarcodeScanner.toggle()
                    }) {
                        Image(systemName: "barcode.viewfinder")
                    }
                }
            }
            
            if selection == Tab.notifications {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            notificationManager.deleteAll()
                        }) {
                            Label("Delete all notifications", systemImage: "trash")
                        }
                    } label: {
                        Label("Mark all as read", systemImage: "checkmark.circle")
                    } primaryAction: {
                        notificationManager.markAllAsRead()
                    }
                }
            }
        }
    }
}

enum Tab: Int, Equatable {
    case activity = 1
    case search = 2
    case notifications = 3
    case profile = 4

    var title: String {
        switch self {
        case .activity:
            return "Activity"
        case .search:
            return "Search"
        case .notifications:
            return "Notifications"
        case .profile:
            return ""
        }
    }
}
