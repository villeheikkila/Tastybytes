import Models
import Observation
import OSLog
import Repositories
import SwiftUI

@Observable
final class Router {
    private let logger = Logger(category: "Router")
    private var isRestored = false

    var path: [Screen] = []
    let tab: Tab

    init(tab: Tab) {
        self.tab = tab
        restoreState()
    }

    func restoreState() {
        guard !isRestored else { return }
        guard let data = try? Data(contentsOf: tab.cachesDirectoryPath) else { return }
        do {
            path = try JSONDecoder().decode([Screen].self, from: data)
            isRestored = true
            logger.info("Navigation stack restored")
        } catch {
            logger.error("Failed to load stored navigation stack. Error \(error) (\(#file):\(#line))")
        }
    }

    func storeState() {
        Task.detached {
            do {
                try JSONEncoder().encode(self.path).write(to: self.tab.cachesDirectoryPath)
                self.logger.info("Navigation stack stored")
            } catch {
                self.logger.error("Failed to store navigation stack. Error \(error) (\(#file):\(#line))")
            }
        }
    }

    func navigate(screen: Screen, resetStack: Bool = false) {
        if resetStack {
            reset()
        }
        path.append(screen)
    }

    func reset() {
        path = []
    }

    func removeLast() {
        path.removeLast()
    }

    func fetchAndNavigateTo(_ repository: RepositoryProtocol, _ destination: NavigatablePath,
                            resetStack: Bool = false)
    {
        Task {
            switch destination {
            case let .product(id):
                switch await repository.product.getById(id: id) {
                case let .success(product):
                    await MainActor.run {
                        self.navigate(screen: .product(product), resetStack: resetStack)
                    }
                case let .failure(error):
                    await MainActor.run {
                        self.navigate(
                            screen: .error(reason: "Failed to load requested product page"),
                            resetStack: resetStack
                        )
                    }
                    logger.error("Request for product with \(id) failed. Error: \(error) (\(#file):\(#line))")
                }
            case let .productWithBarcode(id, barcode):
                switch await repository.product.getById(id: id) {
                case let .success(product):
                    await MainActor.run {
                        self.navigate(screen: .productFromBarcode(product, barcode))
                    }
                case let .failure(error):
                    await MainActor.run {
                        self.navigate(
                            screen: .error(reason: "Failed to load requested product page"),
                            resetStack: resetStack
                        )
                    }
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
