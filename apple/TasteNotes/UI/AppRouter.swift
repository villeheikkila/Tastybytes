import SwiftUI

public struct WithRoutes<RootView: View>: View {
  let view: () -> RootView
  @EnvironmentObject private var profileManager: ProfileManager

  public init(
    @ViewBuilder view: @escaping () -> RootView
  ) {
    self.view = view
  }

  public var body: some View {
    view()
      .navigationDestination(for: CheckIn.self) { checkIn in
        CheckInScreenView(checkIn: checkIn)
      }
      .navigationDestination(for: Profile.self) { profile in
        ProfileTabView(profile: profile)
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
          FriendsScreenView(profile: profileManager.getProfile())
        case .settings:
          PreferencesScreenView()
        case let .activity(profile):
          ActivityTabView(profile: profile)
        case let .location(location):
          LocationScreenView(location: location)
        case let .profileProducts(profile):
          ProfileProductListView(profile: profile)
        case let .addProduct(initialBarcode):
          ProductSheetView(mode: .new, initialBarcode: initialBarcode)
        case let .checkIn(checkIn):
          CheckInScreenView(checkIn: checkIn)
        case let .profile(profile):
          ProfileTabView(profile: profile)
        case let .product(product):
          ProductScreenView(product: product)
        case let .friends(profile):
          FriendsScreenView(profile: profile)
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
