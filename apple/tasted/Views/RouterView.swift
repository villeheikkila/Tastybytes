import GoTrue
import SwiftUI

private enum ProfileEnvironmentKey: EnvironmentKey {
    static var defaultValue: Profile?
}

extension EnvironmentValues {
    public var profile: Profile? {
        get { self[ProfileEnvironmentKey.self] }
        set { self[ProfileEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func withProfile(_ profile: Profile?) -> some View {
        environment(\.profile, profile)
    }
}

class CurrentProfile: ObservableObject {
    @Published var currentProfile: Profile = Profile(id: UUID(), first_name: nil, last_name: nil, username: "", avatar_url: nil)

    init() {
        Task {
            getProfile()
        }
    }

    func getProfile() {
        let query = API.supabase.database
            .from("profiles")
            .select(columns: "*", count: .exact)
            .eq(column: "id", value: API.supabase.auth.session?.user.id.uuidString ?? "")
            .limit(count: 1)
            .single()

        Task {
            let decodedProfile = try await query
                .execute()
                .decoded(to: Profile.self)

            DispatchQueue.main.async {
                self.currentProfile = decodedProfile
            }
        }
    }
}

struct RouterView: View {
    @StateObject private var profile = CurrentProfile()

    var body: some View {
        UserProviderView(supabaseClient: API.supabase) {
            AuthView(supabaseClient: API.supabase, loadingContent: ProgressView.init) { session in
                NavigationStack {
                    NavigationBarView()
                        .navigationBarItems(leading:
                            NavigationLink(destination: FriendsView()) {
                                Image(systemName: "person.2").imageScale(.large)

                            },
                            trailing: NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gear").imageScale(.large)
                            })

                }

            }
            .environmentObject(profile)
        }
    }
}

enum Route: Hashable {
    case product(ProductResponse)
    case profile(ProfileResponse)
    case checkIn(CheckInResponse)
}

struct NavigationBarView: View {
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
            ProfileView(userId: getCurrentUserIdUUID())
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .navigationDestination(for: CheckInResponse.self) { checkIn in
            CheckInPageView(checkIn: checkIn)
        }
        .navigationDestination(for: ProfileResponse.self) { profile in
            ProfileView(userId: profile.id )
        }
        .navigationDestination(for: ProductResponse.self) { product in
            ProductPageView(product: product)
        }
    }
}

struct RouterView_Previews: PreviewProvider {
    static var previews: some View {
        RouterView()
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
