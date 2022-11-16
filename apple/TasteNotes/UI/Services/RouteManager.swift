import SwiftUI

@MainActor
class RouteManager: ObservableObject {
    @Published var path = NavigationPath()

    func gotoHomePage() {
        path = NavigationPath()
    }

    func removeLast() {
        path.removeLast()
    }

    func tapOnSecondPage() {
        path.removeLast()
    }

    func navigateTo(destination: some Hashable, resetStack: Bool) {
        if resetStack {
            path.removeLast(path.count)
        }
        path.append(destination)
    }

    func fetchAndNavigateTo(_ destination: FetchAndNavigateToDestination) {
        Task {
            switch destination {
            case let .product(id):
                switch await repository.product.getById(id: id) {
                case let .success(product):
                    self.navigateTo(destination: product, resetStack: true)
                case let .failure(error):
                    print(error)
                }
            case let .checkIn(id):
                switch await repository.checkIn.getById(id: id) {
                case let .success(checkIn):
                    self.navigateTo(destination: checkIn, resetStack: true)
                case let .failure(error):
                    print(error)
                }
            case let .company(id):
                switch await repository.company.getById(id: id) {
                case let .success(company):
                    print(company)
                    self.navigateTo(destination: company, resetStack: true)
                case let .failure(error):
                    print(error)
                }
            case let .profile(id):
                switch await repository.profile.getById(id: id) {
                case let .success(profile):
                    self.navigateTo(destination: profile, resetStack: true)
                case let .failure(error):
                    print(error)
                }
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

extension URL {
    var isDeepLink: Bool {
        return scheme == "tastenotes"
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
        guard let hostIdentifier = hostIdentifier,
              pathComponents.count > 1 else {
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
