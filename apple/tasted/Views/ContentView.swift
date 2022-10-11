import GoTrue
import SwiftUI

struct ContentView: View {
    var body: some View {
        UserProviderView(supabaseClient: API.supabase) {
            AuthView(supabaseClient: API.supabase, loadingContent: ProgressView.init) { session in
                NavigationView {
                    NavigationBarView(user: session.user)
                        .navigationBarItems(leading:
                                                NavigationLink(destination: FriendsView()) {
                            Image(systemName: "person.2").imageScale(.large)
                            
                            
                        },
                                            trailing:  NavigationLink(destination: SettingsView(user: session.user)) {
                            Image(systemName: "gear").imageScale(.large)
                        }
                                            
                        )
                }
            }
        }
    }
}

struct NavigationBarView: View {
    let user: User
    
    var body: some View {
        TabView {
            ActivityView()
            .tabItem {
                Image(systemName: "list.star")
                Text("Activity")
            }
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            ProfileView(user:user)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Encodable {
    func jsonFormatted() -> String {
        let encoder = JSONEncoder.goTrue
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try! encoder.encode(self)
        return String(data: data, encoding: .utf8)!
    }
}
