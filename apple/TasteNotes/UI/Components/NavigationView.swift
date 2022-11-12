import Foundation
import SwiftUI

struct NavigationStackView: View {
    @StateObject var navigator = Navigator()

    
    var body: some View {
        NavigationStack(path: $navigator.path) {
            AddRoutesView {
                TabbarView()
            }
            .navigationBarItems(leading:
                                    NavigationLink(value: Route.currentUserFriends) {
                Image(systemName: "person.2").imageScale(.large)
                
            },
                                trailing: NavigationLink(value: Route.settings) {
                Image(systemName: "gear").imageScale(.large)
            })
        }.environmentObject(navigator)
    }
}

class Navigator: ObservableObject {
    @Published var path = NavigationPath()
    
    func gotoHomePage() {
        path.removeLast(path.count)
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

enum Route: Hashable {
    case product(ProductJoined)
    case profile(Profile)
    case checkIn(CheckIn)
    case companies(Company)
    case settings
    case currentUserFriends
    case friends(Profile)
    case activity(Profile)
    case addProduct
}

struct AddRoutesView<Content: View>: View {
    var content: () -> Content
    
    var body: some View {
        content()
            .navigationDestination(for: CheckIn.self) { checkIn in
                CheckInScreenView(checkIn: checkIn)
            }
            .navigationDestination(for: Profile.self) { profile in
                ProfileScreenView(profile: profile)
            }
            .navigationDestination(for: ProductJoined.self) { product in
                ProductScreenView(product: product)
            }
            .navigationDestination(for: Company.self) { company in
                CompanyScreenView(company: company)
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case let .companies(company):
                    CompanyScreenView(company: company)
                case .currentUserFriends:
                    WithProfile {
                        profile in FriendsScreenView(profile: profile)
                    }
                case .settings:
                    PreferencesScreenView()
                case let .activity(profile):
                    ActivityScreenView(profile: profile)
                case .addProduct:
                    ProductSheetView()
                case let .checkIn(checkIn):
                    CheckInScreenView(checkIn: checkIn)
                case let .profile(profile):
                    ProfileScreenView(profile: profile)
                case let .product(product):
                    ProductScreenView(product: product)
                case let .friends(profile):
                    FriendsScreenView(profile: profile)
                }
            }
    }
}
