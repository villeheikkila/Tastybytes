import GoTrue
import SwiftUI

class Navigator: ObservableObject {
    @Published var path = NavigationPath()

    func gotoHomePage() {
        path.removeLast(path.count)
        path.append(Route.activity)
    }
    
    func removeLast() {
        path.removeLast()
    }
    
    func tapOnSecondPage() {
        path.removeLast()
    }
    
    func navigateTo(destination: some Hashable, resetStack: Bool) {
        if resetStack {
            path.removeLast(path.count)
        }
        path.append(destination)
    }
}

struct RootView: View {
    @StateObject var navigator = Navigator()
    
    var body: some View {
        UserProviderView(supabaseClient: Supabase.client) {
            AuthView(loadingContent: ProgressView.init) { _ in
                NavigationStack(path: $navigator.path) {
                    AddNavigation {
                        Tabbar()
                    }.navigationBarItems(leading:
                                            NavigationLink(value: Route.currentUserFriends) {
                                                Image(systemName: "person.2").imageScale(.large)

                                            },
                                            trailing: NavigationLink(value: Route.settings) {
                                                Image(systemName: "gear").imageScale(.large)
                                            })
                }
            }
        }
        .environmentObject(navigator)
        
    }
}

enum Route: Hashable {
    case product(Product)
    case profile(Profile)
    case checkIn(CheckIn)
    case settings
    case currentUserFriends
    case friends(Profile)
    case activity
    case addProduct
}

struct AddNavigation<Content: View>: View {
    var content: () -> Content

    var body: some View {
        content()
            .navigationDestination(for: CheckIn.self) { checkIn in
                CheckInPageView(checkIn: checkIn)
            }
            .navigationDestination(for: Profile.self) { profile in
                ProfileView(userId: profile.id)
            }
            .navigationDestination(for: Product.self) { product in
                ProductPageView(product: product)
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .currentUserFriends:
                    FriendsScreenView()
                case .settings:
                    SettingsView()
                case .activity:
                    ActivityView()
                case .addProduct:
                    AddProductScreenView()
                case let .checkIn(checkIn):
                    CheckInPageView(checkIn: checkIn)
                case let .profile(profile):
                    ProfileView(userId: profile.id)
                case let .product(product):
                    ProductPageView(product: product)
                case let .friends(profile):
                    FriendsScreenView(profile: profile)
                }
            }
    }
}

struct Tabbar: View {
    var body: some View {
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
            ProfileView(userId: SupabaseAuthRepository().getCurrentUserId())
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}

struct RouterView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
