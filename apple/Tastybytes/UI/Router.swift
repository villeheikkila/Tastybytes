import os
import SwiftUI

struct InitializeRouter<Content: View>: View {
  @StateObject private var router = Router()
  let client: Client
  var content: (_ router: Router) -> Content

  init(_ client: Client, @ViewBuilder content: @escaping (_ router: Router) -> Content) {
    self.client = client
    self.content = content
  }

  var body: some View {
    NavigationStack(path: $router.path) {
      content(router)
        .navigationDestination(for: Screen.self) { screen in
          screen.view(client)
        }
        .sheet(item: $router.sheet) { sheet in
          NavigationStack {
            sheet.view(client)
          }
          .presentationDetents(sheet.detents)
          .presentationCornerRadius(sheet.cornerRadius)
          .presentationBackground(sheet.background)
          .sheet(item: $router.nestedSheet, content: { nestedSheet in
            NavigationStack {
              nestedSheet.view(client)
                .presentationDetents(nestedSheet.detents)
                .presentationCornerRadius(nestedSheet.cornerRadius)
                .presentationBackground(nestedSheet.background)
            }
          })
        }
        .onOpenURL { url in
          if let detailPage = url.detailPage {
            router.fetchAndNavigateTo(client, detailPage, resetStack: true)
          }
        }
    }
    .environmentObject(router)
  }
}

@MainActor
class Router: ObservableObject {
  private let logger = getLogger(category: "Router")
  @Published var path: [Screen] = []
  @Published var sheet: Sheet?
  @Published var nestedSheet: Sheet?

  func navigate(to: Screen, resetStack: Bool) {
    if resetStack {
      path = []
    }
    path.append(to)
  }

  func openSheet(_ to: Sheet) {
    if sheet != nil {
      nestedSheet = to
    } else {
      sheet = to
    }
  }

  func reset() {
    path = []
  }

  func removeLast() {
    path.removeLast()
  }

  func fetchAndNavigateTo(_ client: Client, _ destination: NavigatablePath, resetStack: Bool) {
    Task {
      switch destination {
      case let .product(id):
        switch await client.product.getById(id: id) {
        case let .success(product):
          self.navigate(to: .product(product), resetStack: resetStack)
        case let .failure(error):
          logger.error("request for product with \(id) failed: \(error.localizedDescription)")
        }
      case let .checkIn(id):
        switch await client.checkIn.getById(id: id) {
        case let .success(checkIn):
          self.navigate(to: .checkIn(checkIn), resetStack: resetStack)
        case let .failure(error):
          logger.error("request for check-in with \(id) failed: \(error.localizedDescription)")
        }
      case let .company(id):
        switch await client.company.getById(id: id) {
        case let .success(company):
          self.navigate(to: .company(company), resetStack: resetStack)
        case let .failure(error):
          logger.error("request for company with \(id) failed: \(error.localizedDescription)")
        }
      case let .brand(id):
        switch await client.brand.getJoinedById(id: id) {
        case let .success(brand):
          self.navigate(to: .brand(brand), resetStack: resetStack)
        case let .failure(error):
          logger.error("request for brand with \(id) failed: \(error.localizedDescription)")
        }
      case let .profile(id):
        switch await client.profile.getById(id: id) {
        case let .success(profile):
          self.navigate(to: .profile(profile), resetStack: resetStack)
        case let .failure(error):
          logger
            .error(
              "request for profile with \(id.uuidString.lowercased()) failed: \(error.localizedDescription)"
            )
        }
      case let .location(id):
        switch await client.location.getById(id: id) {
        case let .success(location):
          self.navigate(to: .location(location), resetStack: resetStack)
        case let .failure(error):
          logger.error("request for location with \(id) failed: \(error.localizedDescription)")
        }
      }
    }
  }
}

enum NavigatablePath {
  case product(id: Int)
  case checkIn(id: Int)
  case company(id: Int)
  case profile(id: UUID)
  case location(id: UUID)
  case brand(id: Int)

  var urlString: String {
    switch self {
    case let .profile(id):
      return "\(Config.baseUrl)/\(PathIdentifier.profiles)/\(id.uuidString.lowercased())"
    case let .checkIn(id):
      return "\(Config.baseUrl)/\(PathIdentifier.checkins)/\(id)"
    case let .product(id):
      return "\(Config.baseUrl)/\(PathIdentifier.products)/\(id)"
    case let .company(id):
      return "\(Config.baseUrl)/\(PathIdentifier.companies)/\(id)"
    case let .brand(id):
      return "\(Config.baseUrl)/\(PathIdentifier.brands)/\(id)"
    case let .location(id):
      return "\(Config.baseUrl)/\(PathIdentifier.locations)/\(id.uuidString.lowercased())"
    }
  }

  var url: URL {
    // swiftlint:disable force_unwrapping
    URL(string: urlString)!
    // swiftlint:enable force_unwrapping
  }
}

enum PathIdentifier: Hashable {
  case checkins, products, profiles, companies, locations, brands
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
    case "brands": return .brands
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
    case .brands:
      guard let id = Int(path) else {
        return nil
      }
      return .brand(id: id)
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
