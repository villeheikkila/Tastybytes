import SwiftUI

@MainActor class Router: ObservableObject {
  @Published public var path: [Route] = []

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

  func fetchAndNavigateTo(_ destination: NavigatablePath) {
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
      case let .location(id):
        switch await repository.location.getById(id: id) {
        case let .success(location):
          self.navigate(to: .location(location), resetStack: true)
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

  @ViewBuilder
  var view: some View {
    switch self {
    case let .company(company):
      CompanyScreenView(company: company)
    case .currentUserFriends:
      CurrentUserFriendsScreenView()
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

@MainActor
extension View {
  func withRoutes() -> some View {
    navigationDestination(for: Route.self) { route in route.view }
  }
}

enum NavigatablePath {
  case product(id: Int)
  case checkIn(id: Int)
  case company(id: Int)
  case profile(id: UUID)
  case location(id: UUID)

  var url: URL {
    switch self {
    case let .profile(id):
      return URL(string: "\(Config.baseUrl)/\(PathIdentifier.profiles)/\(id)")!
    case let .checkIn(id):
      return URL(string: "\(Config.baseUrl)/\(PathIdentifier.checkins)/\(id)")!
    case let .product(id):
      return URL(string: "\(Config.baseUrl)/\(PathIdentifier.products)/\(id)")!
    case let .company(id):
      return URL(string: "\(Config.baseUrl)/\(PathIdentifier.companies)/\(id)")!
    case let .location(id):
      return URL(string: "\(Config.baseUrl)/\(PathIdentifier.locations)/\(id)")!
    }
  }
}

enum PathIdentifier: Hashable {
  case checkins, products, profiles, companies, locations
}

extension URL {
  var isUniversalLink: Bool {
    scheme == "https"
  }

  var pathIdentifier: PathIdentifier? {
    guard isUniversalLink, pathComponents.count == 3 else { return nil }

    switch pathComponents[1] {
    case "checkins": return .checkins
    case "products": return .products
    case "profiles": return .profiles
    case "companies": return .companies
    case "locations": return .locations
    default: return nil
    }
  }

  var detailPage: NavigatablePath? {
    guard let pathIdentifier
    else {
      return nil
    }

    let path = pathComponents[2]

    switch pathIdentifier {
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
      return .profile(id: uuid)
    case .companies:
      guard let id = Int(path) else {
        return nil
      }
      return .company(id: id)
    case .locations:
      guard let id = UUID(uuidString: path) else { return nil }
      return .location(id: id)
    }
  }
}
