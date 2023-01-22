import SwiftUI

@MainActor
class Router: ObservableObject {
  @Published public var path: [Route] = []

  init() {}

  func navigate(to: Route, resetStack: Bool) {
    if resetStack {
      path.removeLast(path.count)
    }
    path.append(to)
  }

  func reset() {
    path = []
  }

  func removeLast() {
    path.removeLast()
  }

  func fetchAndNavigateTo(_ destination: FetchAndNavigateToDestination) {
    Task {
      switch destination {
      case let .product(id):
        switch await repository.product.getById(id: id) {
        case let .success(product):
          self.navigate(to: .product(product), resetStack: true)
        case let .failure(error):
          print(error)
        }
      case let .checkIn(id):
        switch await repository.checkIn.getById(id: id) {
        case let .success(checkIn):
          self.navigate(to: .checkIn(checkIn), resetStack: true)
        case let .failure(error):
          print(error)
        }
      case let .company(id):
        switch await repository.company.getById(id: id) {
        case let .success(company):
          self.navigate(to: .company(company), resetStack: true)
        case let .failure(error):
          print(error)
        }
      case let .profile(id):
        switch await repository.profile.getById(id: id) {
        case let .success(profile):
          self.navigate(to: .profile(profile), resetStack: true)
        case let .failure(error):
          print(error)
        }
      }
    }
  }
}

enum Route: Hashable {
  case product(Product.Joined)
  case profile(Profile)
  case checkIn(CheckIn)
  case location(Location)
  case company(Company)
  case profileProducts(Profile)
  case settings
  case currentUserFriends
  case friends(Profile)
  case addProduct(Barcode?)
}

struct WithRoutes<RootView: View>: View {
  @EnvironmentObject private var profileManager: ProfileManager

  let view: () -> RootView

  init(
    @ViewBuilder view: @escaping () -> RootView
  ) {
    self.view = view
  }

  var body: some View {
    view()
      .navigationDestination(for: Route.self) { route in
        switch route {
        case let .company(company):
          CompanyScreenView(company: company)
        case .currentUserFriends:
          FriendsScreenView(profile: profileManager.getProfile())
        case .settings:
          PreferencesScreenView()
        case let .location(location):
          LocationScreenView(location: location)
        case let .profileProducts(profile):
          ProfileProductListView(profile: profile)
        case let .addProduct(initialBarcode):
          ProductSheetView(mode: .new, initialBarcode: initialBarcode)
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

enum FetchAndNavigateToDestination {
  case product(id: Int)
  case checkIn(id: Int)
  case company(id: Int)
  case profile(id: UUID)
}

enum HostIdentifier: Hashable {
  case checkins, products, profiles, companies
}

func createLinkToScreen(_ destination: FetchAndNavigateToDestination) -> URL {
  switch destination {
  case let .profile(id):
    return URL(string: "\(Config.baseUrl)/\(HostIdentifier.profiles)/\(id)")!
  case let .checkIn(id):
    return URL(string: "\(Config.baseUrl)/\(HostIdentifier.checkins)/\(id)")!
  case let .product(id):
    return URL(string: "\(Config.baseUrl)/\(HostIdentifier.products)/\(id)")!
  case let .company(id):
    return URL(string: "\(Config.baseUrl)/\(HostIdentifier.companies)/\(id)")!
  }
}

extension URL {
  var isDeepLink: Bool {
    scheme == Config.appName.lowercased()
  }

  var hostIdentifier: HostIdentifier? {
    guard isDeepLink else { return nil }

    switch host {
    case "checkins": return .checkins
    case "products": return .products
    case "profiles": return .profiles
    case "companies": return .companies
    default: return nil
    }
  }

  var detailPage: FetchAndNavigateToDestination? {
    guard let hostIdentifier,
          pathComponents.count > 1
    else {
      return nil
    }

    let path = pathComponents[1]

    switch hostIdentifier {
    case .products:
      guard let id = Int(path) else {
        return nil
      }
      return .product(id: id)
    case .checkins:
      guard let id = Int(path) else {
        return nil
      }
      return .checkIn(id: id)
    case .profiles:
      guard let uuid = UUID(uuidString: path) else {
        return nil
      }
      print(uuid)
      return .profile(id: uuid)
    case .companies:
      guard let id = Int(path) else {
        return nil
      }
      return .company(id: id)
    }
  }
}
