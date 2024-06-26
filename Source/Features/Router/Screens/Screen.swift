import Models
import SwiftUI

enum Screen: Hashable, Codable, Sendable {
    case product(Product.Joined)
    case productFromBarcode(Product.Joined, Barcode)
    case profile(Profile)
    case checkIn(CheckIn)
    case location(Location)
    case company(Company)
    case brand(Brand.JoinedSubBrandsProductsCompany)
    case fetchBrand(Brand.JoinedCompany)
    case fetchSubBrand(SubBrand.JoinedBrand)
    case profileProducts(Profile)
    case profileWishlist(Profile)
    case profileProductsByFilter(Profile, Product.Filter)
    case profileStatistics(Profile)
    case profileStatisticsUniqueProducts(Profile)
    case profileStatisticsTopLocations(Profile)
    case profileLocations(Profile)
    case profileCheckIns(Profile, ProfileCheckInListFilter)
    case settings
    case currentUserFriends
    case friends(Profile)
    case addProduct(Barcode?)
    case productFeed(Product.FeedType)
    case flavorManagement
    case verification
    case duplicateProducts
    case categoryManagement
    case profileSettings
    case privacySettings
    case accountSettings
    case appearanaceSettings
    case notificationSettingsScreen
    case appIcon
    case blockedUsers
    case contributions
    case about
    case reports
    case locationManagement
    case error(reason: String)

    @MainActor
    @ViewBuilder
    var view: some View {
        switch self {
        case let .company(company):
            CompanyScreen(company: company)
        case let .fetchSubBrand(subBrand):
            BrandScreen(brand: .init(subBrand: subBrand), initialScrollPosition: subBrand)
        case let .brand(brand):
            BrandScreen(brand: brand)
        case let .fetchBrand(brand):
            BrandScreen(brand: .init(brand: brand))
        case .currentUserFriends:
            CurrentUserFriendsScreen(showToolbar: true)
        case .settings:
            SettingsScreen()
        case let .location(location):
            LocationScreen(location: location)
        case let .profileProducts(profile):
            ProfileProductListView(profile: profile, locked: false)
        case let .profileStatistics(profile):
            ProfileStatisticsScreen(profile: profile)
        case let .profileStatisticsUniqueProducts(profile):
            ProfileStatisticsUniqueByCategoryScreen(profile: profile)
        case let .profileWishlist(profile):
            ProfileWishlistScreen(profile: profile)
        case let .profileLocations(profile):
            ProfileLocationsScreen(profile: profile)
        case let .profileCheckIns(profile, filter):
            ProfileCheckInsList(profile: profile, filter: filter)
        case let .profileStatisticsTopLocations(profile):
            ProfileTopLocationsScreen(profile: profile)
        case let .addProduct(initialBarcode):
            ProductMutationView(mode: .new(onCreate: nil), initialBarcode: initialBarcode)
        case let .checkIn(checkIn):
            CheckInScreen(checkIn: checkIn)
        case let .profile(profile):
            ProfileScreen(profile: profile)
        case let .profileProductsByFilter(profile, filter):
            ProfileProductListView(profile: profile, locked: true, productFilter: filter)
        case let .product(product):
            ProductScreen(product: product)
        case let .productFromBarcode(product, barcode):
            ProductScreen(product: product, loadedWithBarcode: barcode)
        case let .friends(profile):
            FriendsScreen(profile: profile)
        case let .productFeed(feed):
            ProductFeedScreen(feed: feed)
        case .flavorManagement:
            FlavorManagementScreen()
        case .verification:
            VerificationScreen()
        case .duplicateProducts:
            DuplicateProductScreen()
        case .categoryManagement:
            CategoryManagementScreen()
        case .profileSettings:
            ProfileSettingsScreen()
        case .accountSettings:
            AccountSettingsScreen()
        case .appearanaceSettings:
            AppearanceSettingsScreen()
        case .privacySettings:
            PrivacySettingsScreen()
        case .notificationSettingsScreen:
            NotificationSettingsScreen()
        case .appIcon:
            AppIconScreen()
        case .blockedUsers:
            BlockedUsersScreen()
        case .contributions:
            ContributionsScreen()
        case .about:
            AboutScreen()
        case .reports:
            ReportScreen()
        case let .error(reason):
            ErrorScreen(reason: reason)
        case .locationManagement:
            LocationManagementScreen()
        }
    }
}
