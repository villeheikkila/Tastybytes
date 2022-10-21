import SwiftUI

struct TabbarView: View {
    @EnvironmentObject var currentProfile: CurrentProfile
    
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
                NotificationView()
                    .tabItem {
                        Image(systemName: "bell")
                        Text("Notifications")
                    }
                    .badge(currentProfile.notifications.count)
                ProfileView(profile: profile)
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
            }
        }
    }
}

