import GoTrue
import SwiftUI

private enum ProfileEnvironmentKey: EnvironmentKey {
    static var defaultValue: Profile?
}

struct RootView: View {
    var body: some View {
        UserProviderView(supabaseClient: Supabase.client) {
            AuthView(supabaseClient: Supabase.client, loadingContent: ProgressView.init) { _ in
                NavigationStack {
                    AddNavigation {
                        Tabbar()
                    }
                }
            }
        }
    }
}

enum Route: Hashable {
    case product(Product)
    case profile(Profile)
    case checkIn(CheckIn)
    case settings
    case friends
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
                case .friends:
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
        }.navigationBarItems(leading:
            NavigationLink(value: Route.friends) {
                Image(systemName: "person.2").imageScale(.large)

            },
            trailing: NavigationLink(value: Route.settings) {
                Image(systemName: "gear").imageScale(.large)
            })
    }
}

struct RouterView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
