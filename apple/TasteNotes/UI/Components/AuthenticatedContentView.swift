import FirebaseMessaging
import Foundation
import SwiftUI

struct AuthenticatedContentView: View {
    @StateObject var routeManager = RouteManager()
    @StateObject var profileManager = ProfileManager()
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        NavigationStack(path: $routeManager.path) {
            if profileManager.isLoggedIn, let currentProfile = profileManager.getProfile() {
                TabbarView(profile: currentProfile)
                    .navigationDestination(for: CheckIn.self) { checkIn in
                        CheckInScreenView(checkIn: checkIn)
                    }
                    .navigationDestination(for: Profile.self) { profile in
                        ProfileScreenView(profile: profile)
                    }
                    .navigationDestination(for: Product.Joined.self) { product in
                        ProductScreenView(product: product)
                    }
                    .navigationDestination(for: Location.self) { location in
                        LocationScreenView(location: location)
                    }
                    .navigationDestination(for: Company.self) { company in
                        CompanyScreenView(company: company)
                    }
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case let .companies(company):
                            CompanyScreenView(company: company)
                        case .currentUserFriends:
                            FriendsScreenView(profile: currentProfile)
                        case .settings:
                            PreferencesScreenView()
                        case let .activity(profile):
                            ActivityScreenView(profile: profile)
                        case let .location(location):
                            LocationScreenView(location: location)
                        case let .profileProducts(profile):
                            ProfileProductListView(profile: profile)
                        case let .addProduct(initialBarcode):
                            ProductSheetView(initialBarcode: initialBarcode)
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
        .environmentObject(routeManager)
        .environmentObject(profileManager)
        .preferredColorScheme(profileManager.colorScheme)
        .task {
            profileManager.refresh()
            notificationManager.refresh()
            notificationManager.refreshAPNS()
        }
        .onOpenURL { url in
            if let detailPage = url.detailPage {
                routeManager.fetchAndNavigateTo(detailPage)
            }
        }
    }
}

enum Route: Hashable {
    case product(Product.Joined)
    case profile(Profile)
    case checkIn(CheckIn)
    case location(Location)
    case companies(Company)
    case profileProducts(Profile)
    case settings
    case currentUserFriends
    case friends(Profile)
    case activity(Profile)
    case addProduct(Barcode?)
}
