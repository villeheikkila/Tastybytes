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
                            FriendsScreenView(profile: currentProfile)
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
        .environmentObject(routeManager)
        .environmentObject(profileManager)
        .preferredColorScheme(profileManager.colorScheme)
        .task {
            profileManager.refresh()
            notificationManager.getAll()
        }
        .onOpenURL { url in
            if let detailPage = url.detailPage {
                routeManager.fetchAndNavigateTo(detailPage)
            }
        }
        .task {
            Messaging.messaging().token { token, error in
                if let error = error {
                    print("Error fetching FCM registration token: \(error)")
                } else if let token = token {
                    Task {
                        switch await repository.profile.uploadPushNotificationToken(token: Profile.PushNotificationToken(firebaseRegistrationToken: token)) {
                        case .success():
                            break
                        case let .failure(error):
                            print("Couldn't save FCM (\(String(describing: token))): \(error)")
                        }
                    }
                }
            }
        }
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
