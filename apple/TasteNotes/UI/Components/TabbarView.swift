import SwiftUI

struct TabbarView: View {
    @EnvironmentObject var currentProfile: CurrentProfile
    @EnvironmentObject var notificationManager: NotificationManager

    var body: some View {
        WithProfile {
            profile in
            TabView {
                ActivityScreenView(profile: profile)
                    .tabItem {
                        Image(systemName: "list.star")
                        Text("Activity")
                    }
                SearchScreenView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                NotificationScreenView()
                    .tabItem {
                        Image(systemName: "bell")
                        Text("Notifications")
                    }
                    .badge(notificationManager.notifications.count)
                ProfileScreenView(profile: profile)
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
            }
        }
    }
}

