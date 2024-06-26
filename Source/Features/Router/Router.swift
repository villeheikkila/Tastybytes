import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
@Observable
final class Router {
    private let logger = Logger(category: "Router")
    var path = [Screen]()
    var sheet: Sheet?
    var alert: AlertError?
    var fullScreenCover: FullScreenCover?

    init(path: [Screen] = [], sheet: Sheet? = nil) {
        self.path = path
        self.sheet = sheet
    }

    func navigate(screen: Screen, resetStack: Bool = false, removeLast: Bool = false) {
        if resetStack {
            reset()
        }
        path.append(screen)
        if removeLast {
            guard path.count >= 2 else { return }
            path.remove(at: path.count - 2)
        }
    }

    func openSheet(_ sheet: Sheet) {
        self.sheet = sheet
    }

    func openAlert(_ alert: AlertError) {
        self.alert = alert
    }

    func openFullScreenCover(_ fullScreenCover: FullScreenCover) {
        self.fullScreenCover = fullScreenCover
    }

    func reset() {
        path = []
    }

    func removeLast() {
        path.removeLast()
    }

    func fetchAndNavigateTo(
        _ repository: RepositoryProtocol,
        _ destination: NavigatablePath,
        resetStack: Bool = false
    ) {
        Task {
            switch destination {
            case let .product(id):
                switch await repository.product.getById(id: id) {
                case let .success(product):
                    self.navigate(screen: .product(product), resetStack: resetStack)
                case let .failure(error):
                    self.navigate(
                        screen: .error(reason: "Failed to load requested product page"),
                        resetStack: resetStack
                    )
                    logger.error("Request for product with \(id) failed. Error: \(error) (\(#file):\(#line))")
                }
            case let .productWithBarcode(id, barcode):
                switch await repository.product.getById(id: id) {
                case let .success(product):
                    self.navigate(screen: .productFromBarcode(product, barcode))
                case let .failure(error):
                    self.navigate(
                        screen: .error(reason: "Failed to load requested product page"),
                        resetStack: resetStack
                    )
                    logger.error("Request for product with \(id) failed. Error: \(error) (\(#file):\(#line))")
                }
            case let .checkIn(id):
                switch await repository.checkIn.getById(id: id) {
                case let .success(checkIn):
                    self.navigate(screen: .checkIn(checkIn), resetStack: resetStack)
                case let .failure(error):
                    self.navigate(
                        screen: .error(reason: "Failed to load requested check-in page"),
                        resetStack: resetStack
                    )
                    logger.error("Request for check-in with \(id) failed. Error: \(error) (\(#file):\(#line))")
                }
            case let .company(id):
                switch await repository.company.getById(id: id) {
                case let .success(company):
                    self.navigate(screen: .company(company), resetStack: resetStack)
                case let .failure(error):
                    self.navigate(
                        screen: .error(reason: "Failed to load requested company page"),
                        resetStack: resetStack
                    )
                    logger.error("Request for company with \(id) failed. Error: \(error) (\(#file):\(#line))")
                }
            case let .brand(id):
                switch await repository.brand.getJoinedById(id: id) {
                case let .success(brand):
                    self.navigate(screen: .brand(brand), resetStack: resetStack)
                case let .failure(error):
                    self.navigate(
                        screen: .error(reason: "Failed to load requested company page"),
                        resetStack: resetStack
                    )
                    logger.error("Request for brand with \(id) failed. Error: \(error) (\(#file):\(#line))")
                }
            case let .profile(id):
                switch await repository.profile.getById(id: id) {
                case let .success(profile):
                    self.navigate(screen: .profile(profile), resetStack: resetStack)
                case let .failure(error):
                    self.navigate(
                        screen: .error(reason: "Failed to load requested profile page"),
                        resetStack: resetStack
                    )
                    logger
                        .error(
                            "request for profile with \(id.uuidString.lowercased()) failed. error: \(error)"
                        )
                }
            case let .location(id):
                switch await repository.location.getById(id: id) {
                case let .success(location):
                    self.navigate(screen: .location(location), resetStack: resetStack)
                case let .failure(error):
                    self.navigate(
                        screen: .error(reason: "Failed to load requested location page"),
                        resetStack: resetStack
                    )
                    logger.error("Request for location with \(id) failed. Error: \(error) (\(#file):\(#line))")
                }
            }
        }
    }
}

struct NavigateOnTapModifier: ViewModifier {
    @Environment(Router.self) private var router

    let action: NavigationAction

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                switch action {
                case let .sheet(sheet):
                    router.openSheet(sheet)
                case let .screen(screen):
                    router.navigate(screen: screen)
                }
            }
            .accessibility(addTraits: .isLink)
    }
}

enum NavigationAction {
    case sheet(Sheet)
    case screen(Screen)
}

extension View {
    func navigateOnTap(_ action: NavigationAction) -> some View {
        modifier(NavigateOnTapModifier(action: action))
    }
}
