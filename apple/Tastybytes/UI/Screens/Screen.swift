import SwiftUI

enum Screen: Hashable {
  case product(Product.Joined)
  case profile(Profile)
  case checkIn(CheckIn)
  case location(Location)
  case company(Company)
  case brand(Brand.JoinedSubBrandsProductsCompany)
  case fetchBrand(Brand.JoinedCompany)
  case profileProducts(Profile)
  case profileStatistics(Profile)
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
  case accountSettings
  case applicationSettings
  case appIcon
  case blockedUsers
  case contributions
  case about
  case error(reason: String)

  @ViewBuilder var view: some View {
    switch self {
    case let .company(company):
      CompanyScreen(company: company)
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
      ProfileProductListView(profile: profile)
    case let .profileStatistics(profile):
      ProfileStatisticsView(profile: profile)
    case let .addProduct(initialBarcode):
      AddProductView(mode: .new, initialBarcode: initialBarcode)
        .navigationTitle("Add Product")
    case let .checkIn(checkIn):
      CheckInScreen(checkIn: checkIn)
    case let .profile(profile):
      ProfileScreen(profile: profile)
    case let .product(product):
      ProductScreen(product: product)
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
    case .applicationSettings:
      ApplicationSettingsScreen()
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
