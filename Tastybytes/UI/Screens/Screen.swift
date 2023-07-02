import SwiftUI

enum Screen: Hashable, Codable {
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
    case profileLocations(Profile)
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
    case error(reason: String)

    @ViewBuilder var view: some View {
        switch self {
        case let .company(company):
            CompanyScreen(company: company)
        case let .fetchSubBrand(subBrand):
            BrandScreen(
                brand: Brand
                    .JoinedSubBrandsProductsCompany(
                        id: subBrand.brand.id,
                        name: subBrand.brand.name,
                        isVerified: subBrand.brand.isVerified,
                        brandOwner: subBrand.brand.brandOwner,
                        subBrands: []
                    ), refreshOnLoad: true, initialScrollPosition: subBrand
            )
        case let .brand(brand):
            BrandScreen(brand: brand)
        case let .fetchBrand(brand):
            BrandScreen(
                brand: Brand
                    .JoinedSubBrandsProductsCompany(id: brand.id, name: brand.name, isVerified: brand.isVerified,
                                                    brandOwner: brand.brandOwner, subBrands: []), refreshOnLoad: true
            )
        case .currentUserFriends:
            CurrentUserFriendsScreen()
        case .settings:
            SettingsScreen()
        case let .location(location):
            LocationScreen(location: location)
        case let .profileProducts(profile):
            ProfileProductListView(profile: profile, locked: false)
        case let .profileStatistics(profile):
            ProfileStatisticsView(profile: profile)
        case let .profileWishlist(profile):
            ProfileWishlistScreen(profile: profile)
        case let .profileLocations(profile):
            ProfileLocationsScreen(profile: profile)
        case let .addProduct(initialBarcode):
            ProductMutationView(mode: .new, isSheet: false, initialBarcode: initialBarcode)
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
        case let .error(reason):
            ErrorScreen(reason: reason)
        }
    }
}
