import SwiftUI

enum Screen: Hashable {
  case product(Product.Joined)
  case profile(Profile)
  case checkIn(CheckIn)
  case location(Location)
  case company(Company)
  case brand(Brand.JoinedSubBrandsProductsCompany)
  case profileProducts(Profile)
  case profileStatistics(Profile)
  case settings
  case currentUserFriends
  case friends(Profile)
  case addProduct(Barcode?)
  case productFeed(Product.FeedType)
  case flavorManagementScreen
  case verificationScreen
  case duplicateProducts
  case categoryManagement

  @ViewBuilder
  func view(_ client: Client) -> some View {
    switch self {
    case let .company(company):
      CompanyScreen(client, company: company)
    case let .brand(brand):
      BrandScreen(client, brand: brand)
    case .currentUserFriends:
      CurrentUserFriendsScreen(client)
    case .settings:
      SettingsScreen(client)
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
    case .flavorManagementScreen:
      FlavorManagementScreen(client)
    case .verificationScreen:
      VerificationScreen(client)
    case .duplicateProducts:
      DuplicateProductScreen(client)
    case .categoryManagement:
      CategoryManagementScreen(client)
    }
  }
}