import Models
import Repositories
import SwiftUI

enum Screen: Hashable, Sendable {
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
    case reports(ReportFilter? = nil)
    case locationManagement
    case error(reason: String)
    case companyEditSuggestion(company: Binding<Company.Management>)

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
        case let .reports(filter):
            ReportScreen(filter: filter)
        case let .error(reason):
            ErrorScreen(reason: reason)
        case .locationManagement:
            LocationManagementScreen()
        case let .companyEditSuggestion(company):
            CompanyEditSuggestionScreen(company: company)
        }
    }
    
    static func == (lhs: Screen, rhs: Screen) -> Bool {
        switch (lhs, rhs) {
        case (.product(let lhsProduct), .product(let rhsProduct)):
            return lhsProduct == rhsProduct
        case (.productFromBarcode(let lhsProduct, let lhsBarcode), .productFromBarcode(let rhsProduct, let rhsBarcode)):
            return lhsProduct == rhsProduct && lhsBarcode == rhsBarcode
        case (.profile(let lhsProfile), .profile(let rhsProfile)):
            return lhsProfile == rhsProfile
        case (.checkIn(let lhsCheckIn), .checkIn(let rhsCheckIn)):
            return lhsCheckIn == rhsCheckIn
        case (.location(let lhsLocation), .location(let rhsLocation)):
            return lhsLocation == rhsLocation
        case (.company(let lhsCompany), .company(let rhsCompany)):
            return lhsCompany == rhsCompany
        case (.brand(let lhsBrand), .brand(let rhsBrand)):
            return lhsBrand == rhsBrand
        case (.fetchBrand(let lhsBrand), .fetchBrand(let rhsBrand)):
            return lhsBrand == rhsBrand
        case (.fetchSubBrand(let lhsSubBrand), .fetchSubBrand(let rhsSubBrand)):
            return lhsSubBrand == rhsSubBrand
        case (.profileProducts(let lhsProfile), .profileProducts(let rhsProfile)):
            return lhsProfile == rhsProfile
        case (.profileWishlist(let lhsProfile), .profileWishlist(let rhsProfile)):
            return lhsProfile == rhsProfile
        case (.profileProductsByFilter(let lhsProfile, let lhsFilter), .profileProductsByFilter(let rhsProfile, let rhsFilter)):
            return lhsProfile == rhsProfile && lhsFilter == rhsFilter
        case (.profileStatistics(let lhsProfile), .profileStatistics(let rhsProfile)):
            return lhsProfile == rhsProfile
        case (.profileStatisticsUniqueProducts(let lhsProfile), .profileStatisticsUniqueProducts(let rhsProfile)):
            return lhsProfile == rhsProfile
        case (.profileStatisticsTopLocations(let lhsProfile), .profileStatisticsTopLocations(let rhsProfile)):
            return lhsProfile == rhsProfile
        case (.profileLocations(let lhsProfile), .profileLocations(let rhsProfile)):
            return lhsProfile == rhsProfile
        case (.profileCheckIns(let lhsProfile, let lhsFilter), .profileCheckIns(let rhsProfile, let rhsFilter)):
            return lhsProfile == rhsProfile && lhsFilter == rhsFilter
        case (.friends(let lhsProfile), .friends(let rhsProfile)):
            return lhsProfile == rhsProfile
        case (.addProduct(let lhsBarcode), .addProduct(let rhsBarcode)):
            return lhsBarcode == rhsBarcode
        case (.productFeed(let lhsFeed), .productFeed(let rhsFeed)):
            return lhsFeed == rhsFeed
        case (.reports(let lhsFilter), .reports(let rhsFilter)):
            return lhsFilter == rhsFilter
        case (.error(let lhsReason), .error(let rhsReason)):
            return lhsReason == rhsReason
        case (.companyEditSuggestion(let lhsCompany), .companyEditSuggestion(let rhsCompany)):
            return lhsCompany.wrappedValue == rhsCompany.wrappedValue
        case (.settings, .settings),
             (.currentUserFriends, .currentUserFriends),
             (.flavorManagement, .flavorManagement),
             (.verification, .verification),
             (.duplicateProducts, .duplicateProducts),
             (.categoryManagement, .categoryManagement),
             (.profileSettings, .profileSettings),
             (.privacySettings, .privacySettings),
             (.accountSettings, .accountSettings),
             (.appearanaceSettings, .appearanaceSettings),
             (.notificationSettingsScreen, .notificationSettingsScreen),
             (.appIcon, .appIcon),
             (.blockedUsers, .blockedUsers),
             (.contributions, .contributions),
             (.about, .about),
             (.locationManagement, .locationManagement):
            return true
        default:
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .product(let product):
            hasher.combine("product")
            hasher.combine(product)
        case .productFromBarcode(let product, let barcode):
            hasher.combine("productFromBarcode")
            hasher.combine(product)
            hasher.combine(barcode)
        case .profile(let profile):
            hasher.combine("profile")
            hasher.combine(profile)
        case .checkIn(let checkIn):
            hasher.combine("checkIn")
            hasher.combine(checkIn)
        case .location(let location):
            hasher.combine("location")
            hasher.combine(location)
        case .company(let company):
            hasher.combine("company")
            hasher.combine(company)
        case .brand(let brand):
            hasher.combine("brand")
            hasher.combine(brand)
        case .fetchBrand(let brand):
            hasher.combine("fetchBrand")
            hasher.combine(brand)
        case .fetchSubBrand(let subBrand):
            hasher.combine("fetchSubBrand")
            hasher.combine(subBrand)
        case .profileProducts(let profile):
            hasher.combine("profileProducts")
            hasher.combine(profile)
        case .profileWishlist(let profile):
            hasher.combine("profileWishlist")
            hasher.combine(profile)
        case .profileProductsByFilter(let profile, let filter):
            hasher.combine("profileProductsByFilter")
            hasher.combine(profile)
            hasher.combine(filter)
        case .profileStatistics(let profile):
            hasher.combine("profileStatistics")
            hasher.combine(profile)
        case .profileStatisticsUniqueProducts(let profile):
            hasher.combine("profileStatisticsUniqueProducts")
            hasher.combine(profile)
        case .profileStatisticsTopLocations(let profile):
            hasher.combine("profileStatisticsTopLocations")
            hasher.combine(profile)
        case .profileLocations(let profile):
            hasher.combine("profileLocations")
            hasher.combine(profile)
        case .profileCheckIns(let profile, let filter):
            hasher.combine("profileCheckIns")
            hasher.combine(profile)
            hasher.combine(filter)
        case .settings:
            hasher.combine("settings")
        case .currentUserFriends:
            hasher.combine("currentUserFriends")
        case .friends(let profile):
            hasher.combine("friends")
            hasher.combine(profile)
        case .addProduct(let barcode):
            hasher.combine("addProduct")
            hasher.combine(barcode)
        case .productFeed(let feedType):
            hasher.combine("productFeed")
            hasher.combine(feedType)
        case .flavorManagement:
            hasher.combine("flavorManagement")
        case .verification:
            hasher.combine("verification")
        case .duplicateProducts:
            hasher.combine("duplicateProducts")
        case .categoryManagement:
            hasher.combine("categoryManagement")
        case .profileSettings:
            hasher.combine("profileSettings")
        case .privacySettings:
            hasher.combine("privacySettings")
        case .accountSettings:
            hasher.combine("accountSettings")
        case .appearanaceSettings:
            hasher.combine("appearanaceSettings")
        case .notificationSettingsScreen:
            hasher.combine("notificationSettingsScreen")
        case .appIcon:
            hasher.combine("appIcon")
        case .blockedUsers:
            hasher.combine("blockedUsers")
        case .contributions:
            hasher.combine("contributions")
        case .about:
            hasher.combine("about")
        case .reports(let filter):
            hasher.combine("reports")
            hasher.combine(filter)
        case .locationManagement:
            hasher.combine("locationManagement")
        case .error(let reason):
            hasher.combine("error")
            hasher.combine(reason)
        case .companyEditSuggestion(let company):
            hasher.combine("companyEditSuggestion")
            hasher.combine(company.wrappedValue)
        }
    }
}
