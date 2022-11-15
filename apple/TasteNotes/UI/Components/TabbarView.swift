import SwiftUI

struct TabbarView: View {
    let profile: Profile
    @EnvironmentObject var notificationManager: NotificationManager

    var body: some View {
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
        .navigationBarItems(leading:
            NavigationLink(value: Route.currentUserFriends) {
                Image(systemName: "person.2").imageScale(.large)

            },
            trailing: NavigationLink(value: Route.settings) {
                Image(systemName: "gear").imageScale(.large)
            }
        )
    }
}
