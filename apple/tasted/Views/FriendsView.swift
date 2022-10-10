import Foundation
import SwiftUI

struct FriendsView: View {
    var body: some View {
        
        Text("Search")
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
        Text("Friends Screen")
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
    }
}
