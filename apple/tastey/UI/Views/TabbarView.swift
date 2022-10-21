import SwiftUI

struct TabbarView: View {
    var body: some View {
        WithProfile {
            profile in
            TabView {
                ActivityView()
                    .tabItem {
                        Image(systemName: "list.star")
                        Text("Activity")
                    }
                SearchScreenView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                NotificationView(profile: profile)
                    .tabItem {
                        Image(systemName: "bell")
                        Text("Notifications")
                    }.badge(profile.notifications?.count ?? 0)
                ProfileView(profile: profile)
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
            }
        }
    }
}

