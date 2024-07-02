import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
@Observable
final class Router {
    enum Open {
        case sheet(Sheet)
        case screen(Screen, resetStack: Bool = false, removeLast: Bool = false)
        case alert(AlertError)
        case fullScreenCover(FullScreenCover)
    }

    private let logger = Logger(category: "Router")
    var path = [Screen]()
    var sheet: Sheet?
    var alert: AlertError?
    var fullScreenCover: FullScreenCover?

    init(path: [Screen] = [], sheet: Sheet? = nil) {
        self.path = path
        self.sheet = sheet
    }

    func open(_ open: Open) {
        switch open {
        case let .screen(screen, resetStack: resetStack, removeLast: removeLast):
            if resetStack {
                reset()
            }
            path.append(screen)
            if removeLast {
                guard path.count >= 2 else { return }
                path.remove(at: path.count - 2)
            }
        case let .sheet(sheet):
            self.sheet = sheet
        case let .alert(alert):
            self.alert = alert
        case let .fullScreenCover(fullScreenCover):
            self.fullScreenCover = fullScreenCover
        }
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
                    self.open(.screen(.product(product), resetStack: resetStack))
                case let .failure(error):
                    self.open(.screen( .error(reason: "Failed to load requested product page"),
                        resetStack: resetStack
                    ))
                    logger.error("Request for product with \(id) failed. Error: \(error) (\(#file):\(#line))")
                }
            case let .productWithBarcode(id, barcode):
                switch await repository.product.getById(id: id) {
                case let .success(product):
                    self.open(.screen(.productFromBarcode(product, barcode)))
                case let .failure(error):
                    self.open(.screen(.error(reason: "Failed to load requested product page"),
                        resetStack: resetStack
                    ))
                    logger.error("Request for product with \(id) failed. Error: \(error) (\(#file):\(#line))")
                }
            case let .checkIn(id):
                switch await repository.checkIn.getById(id: id) {
                case let .success(checkIn):
                    self.open(.screen(.checkIn(checkIn), resetStack: resetStack))
                case let .failure(error):
                    self.open(.screen(.error(reason: "Failed to load requested check-in page"),
                        resetStack: resetStack
                    ))
                    logger.error("Request for check-in with \(id) failed. Error: \(error) (\(#file):\(#line))")
                }
            case let .company(id):
                switch await repository.company.getById(id: id) {
                case let .success(company):
                    self.open(.screen(.company(company), resetStack: resetStack))
                case let .failure(error):
                    self.open(.screen(.error(reason: "Failed to load requested company page"),
                        resetStack: resetStack
                    ))
                    logger.error("Request for company with \(id) failed. Error: \(error) (\(#file):\(#line))")
                }
            case let .brand(id):
                switch await repository.brand.getJoinedById(id: id) {
                case let .success(brand):
                    self.open(.screen(.brand(brand), resetStack: resetStack))
                case let .failure(error):
                    self.open(.screen(.error(reason: "Failed to load requested company page"),
                        resetStack: resetStack
                    ))
                    logger.error("Request for brand with \(id) failed. Error: \(error) (\(#file):\(#line))")
                }
            case let .profile(id):
                switch await repository.profile.getById(id: id) {
                case let .success(profile):
                    self.open(.screen(.profile(profile), resetStack: resetStack))
                case let .failure(error):
                    self.open(.screen(.error(reason: "Failed to load requested profile page"),
                        resetStack: resetStack
                    ))
                    logger
                        .error(
                            "request for profile with \(id.uuidString.lowercased()) failed. error: \(error)"
                        )
                }
            case let .location(id):
                switch await repository.location.getById(id: id) {
                case let .success(location):
                    self.open(.screen(.location(location), resetStack: resetStack))
                case let .failure(error):
                    self.open(.screen(.error(reason: "Failed to load requested location page"),
                        resetStack: resetStack
                    ))
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
                    router.open(.sheet(sheet))
                case let .screen(screen):
                    router.open(.screen(screen))
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
