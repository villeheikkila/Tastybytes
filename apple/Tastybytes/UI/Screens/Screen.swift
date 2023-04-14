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

  @ViewBuilder
  func view(_ client: Client) -> some View {
    switch self {
    case let .company(company):
      CompanyScreen(client, company: company)
    case let .brand(brand):
      BrandScreen(client, brand: brand)
    case let .fetchBrand(brand):
      BrandScreen(
        client,
        brand: Brand
          .JoinedSubBrandsProductsCompany(id: brand.id, name: brand.name, isVerified: brand.isVerified,
                                          brandOwner: brand.brandOwner, subBrands: []), refreshOnLoad: true
      )
    case .currentUserFriends:
      CurrentUserFriendsScreen(client)
    case .settings:
      SettingsScreen()
    case let .location(location):
      LocationScreen(client, location: location)
    case let .profileProducts(profile):
      ProfileProductListView(client, profile: profile)
    case let .profileStatistics(profile):
      ProfileStatisticsView(client, profile: profile)
    case let .addProduct(initialBarcode):
      AddProductView(client, mode: .new, initialBarcode: initialBarcode)
        .navigationTitle("Add Product")
    case let .checkIn(checkIn):
      CheckInScreen(client, checkIn: checkIn)
    case let .profile(profile):
      ProfileScreen(client, profile: profile)
    case let .product(product):
      ProductScreen(client, product: product)
    case let .friends(profile):
      FriendsScreen(client, profile: profile)
    case let .productFeed(feed):
      ProductFeedScreen(client, feed: feed)
    case .flavorManagement:
      FlavorManagementScreen(client)
    case .verification:
      VerificationScreen(client)
    case .duplicateProducts:
      DuplicateProductScreen(client)
    case .categoryManagement:
      CategoryManagementScreen(client)
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
      ContributionsScreen(client)
    case .about:
      AboutScreen(client)
    }
  }
}
