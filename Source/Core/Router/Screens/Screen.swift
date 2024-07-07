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
    case subBrand(SubBrand.JoinedBrand)
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
    case productFeed(Product.FeedType)
    case flavorAdmin
    case verification
    case duplicateProducts(filter: MarkedAsDuplicateFilter)
    case categoryAdmin
    case profileSettings
    case privacySettings
    case accountSettings
    case appearanaceSettings
    case notificationSettingsScreen
    case appIcon
    case blockedUsers
    case contributions(Profile)
    case about
    case reports(ReportFilter? = nil)
    case locationAdmin
    case error(reason: String)
    case companyEditSuggestion(company: Binding<Company.Management>)
    case categoryServingStyle(category: Models.Category.JoinedSubcategoriesServingStyles)

    @MainActor
    @ViewBuilder
    var view: some View {
        switch self {
        case let .company(company):
            CompanyScreen(company: company)
        case let .subBrand(subBrand):
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
        case .flavorAdmin:
            FlavorAdminScreen()
        case .verification:
            VerificationScreen()
        case let .duplicateProducts(filter):
            DuplicateProductScreen(filter: filter)
        case .categoryAdmin:
            CategoryAdminScreen()
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
        case let .contributions(profile):
            ContributionsScreen(profile: profile)
        case .about:
            AboutScreen()
        case let .reports(filter):
            ReportScreen(filter: filter)
        case let .error(reason):
            ErrorScreen(reason: reason)
        case .locationAdmin:
            LocationAdminScreen()
        case let .companyEditSuggestion(company):
            CompanyEditSuggestionScreen(company: company)
        case let .categoryServingStyle(category: category):
            CategoryServingStyleAdminSheet(category: category)
        }
    }

    static func == (lhs: Screen, rhs: Screen) -> Bool {
        switch (lhs, rhs) {
        case let (.product(lhsProduct), .product(rhsProduct)):
            lhsProduct == rhsProduct
        case let (.productFromBarcode(lhsProduct, lhsBarcode), .productFromBarcode(rhsProduct, rhsBarcode)):
            lhsProduct == rhsProduct && lhsBarcode == rhsBarcode
        case let (.profile(lhsProfile), .profile(rhsProfile)):
            lhsProfile == rhsProfile
        case let (.checkIn(lhsCheckIn), .checkIn(rhsCheckIn)):
            lhsCheckIn == rhsCheckIn
        case let (.location(lhsLocation), .location(rhsLocation)):
            lhsLocation == rhsLocation
        case let (.company(lhsCompany), .company(rhsCompany)):
            lhsCompany == rhsCompany
        case let (.brand(lhsBrand), .brand(rhsBrand)):
            lhsBrand == rhsBrand
        case let (.fetchBrand(lhsBrand), .fetchBrand(rhsBrand)):
            lhsBrand == rhsBrand
        case let (.subBrand(lhsSubBrand), .subBrand(rhsSubBrand)):
            lhsSubBrand == rhsSubBrand
        case let (.profileProducts(lhsProfile), .profileProducts(rhsProfile)):
            lhsProfile == rhsProfile
        case let (.profileWishlist(lhsProfile), .profileWishlist(rhsProfile)):
            lhsProfile == rhsProfile
        case let (.profileProductsByFilter(lhsProfile, lhsFilter), .profileProductsByFilter(rhsProfile, rhsFilter)):
            lhsProfile == rhsProfile && lhsFilter == rhsFilter
        case let (.profileStatistics(lhsProfile), .profileStatistics(rhsProfile)):
            lhsProfile == rhsProfile
        case let (.profileStatisticsUniqueProducts(lhsProfile), .profileStatisticsUniqueProducts(rhsProfile)):
            lhsProfile == rhsProfile
        case let (.profileStatisticsTopLocations(lhsProfile), .profileStatisticsTopLocations(rhsProfile)):
            lhsProfile == rhsProfile
        case let (.profileLocations(lhsProfile), .profileLocations(rhsProfile)):
            lhsProfile == rhsProfile
        case let (.profileCheckIns(lhsProfile, lhsFilter), .profileCheckIns(rhsProfile, rhsFilter)):
            lhsProfile == rhsProfile && lhsFilter == rhsFilter
        case let (.friends(lhsProfile), .friends(rhsProfile)):
            lhsProfile == rhsProfile
        case let (.productFeed(lhsFeed), .productFeed(rhsFeed)):
            lhsFeed == rhsFeed
        case let (.reports(lhsFilter), .reports(rhsFilter)):
            lhsFilter == rhsFilter
        case let (.error(lhsReason), .error(rhsReason)):
            lhsReason == rhsReason
        case let (.companyEditSuggestion(lhsCompany), .companyEditSuggestion(rhsCompany)):
            lhsCompany.wrappedValue == rhsCompany.wrappedValue
        case (.settings, .settings),
             (.currentUserFriends, .currentUserFriends),
             (.flavorAdmin, .flavorAdmin),
             (.verification, .verification),
             (.duplicateProducts, .duplicateProducts),
             (.categoryAdmin, .categoryAdmin),
             (.profileSettings, .profileSettings),
             (.privacySettings, .privacySettings),
             (.accountSettings, .accountSettings),
             (.appearanaceSettings, .appearanaceSettings),
             (.notificationSettingsScreen, .notificationSettingsScreen),
             (.appIcon, .appIcon),
             (.blockedUsers, .blockedUsers),
             (.contributions, .contributions),
             (.about, .about),
             (.locationAdmin, .locationAdmin):
            true
        default:
            false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case let .product(product):
            hasher.combine("product")
            hasher.combine(product)
        case let .productFromBarcode(product, barcode):
            hasher.combine("productFromBarcode")
            hasher.combine(product)
            hasher.combine(barcode)
        case let .profile(profile):
            hasher.combine("profile")
            hasher.combine(profile)
        case let .checkIn(checkIn):
            hasher.combine("checkIn")
            hasher.combine(checkIn)
        case let .location(location):
            hasher.combine("location")
            hasher.combine(location)
        case let .company(company):
            hasher.combine("company")
            hasher.combine(company)
        case let .brand(brand):
            hasher.combine("brand")
            hasher.combine(brand)
        case let .fetchBrand(brand):
            hasher.combine("fetchBrand")
            hasher.combine(brand)
        case let .subBrand(subBrand):
            hasher.combine("fetchSubBrand")
            hasher.combine(subBrand)
        case let .profileProducts(profile):
            hasher.combine("profileProducts")
            hasher.combine(profile)
        case let .profileWishlist(profile):
            hasher.combine("profileWishlist")
            hasher.combine(profile)
        case let .profileProductsByFilter(profile, filter):
            hasher.combine("profileProductsByFilter")
            hasher.combine(profile)
            hasher.combine(filter)
        case let .profileStatistics(profile):
            hasher.combine("profileStatistics")
            hasher.combine(profile)
        case let .profileStatisticsUniqueProducts(profile):
            hasher.combine("profileStatisticsUniqueProducts")
            hasher.combine(profile)
        case let .profileStatisticsTopLocations(profile):
            hasher.combine("profileStatisticsTopLocations")
            hasher.combine(profile)
        case let .profileLocations(profile):
            hasher.combine("profileLocations")
            hasher.combine(profile)
        case let .profileCheckIns(profile, filter):
            hasher.combine("profileCheckIns")
            hasher.combine(profile)
            hasher.combine(filter)
        case .settings:
            hasher.combine("settings")
        case .currentUserFriends:
            hasher.combine("currentUserFriends")
        case let .friends(profile):
            hasher.combine("friends")
            hasher.combine(profile)
        case let .productFeed(feedType):
            hasher.combine("productFeed")
            hasher.combine(feedType)
        case .flavorAdmin:
            hasher.combine("flavorManagement")
        case .verification:
            hasher.combine("verification")
        case let .duplicateProducts(filter):
            hasher.combine("duplicateProducts")
            hasher.combine(filter)
        case .categoryAdmin:
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
        case let .reports(filter):
            hasher.combine("reports")
            hasher.combine(filter)
        case .locationAdmin:
            hasher.combine("locationManagement")
        case let .error(reason):
            hasher.combine("error")
            hasher.combine(reason)
        case let .companyEditSuggestion(company):
            hasher.combine("companyEditSuggestion")
            hasher.combine(company.wrappedValue)
        case let .categoryServingStyle(category):
            hasher.combine("categoryServingStyle")
            hasher.combine(category)
        }
    }
}
