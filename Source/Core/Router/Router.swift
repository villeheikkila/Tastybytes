import EnvironmentModels
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
        case alert(AlertEvent)
        case fullScreenCover(FullScreenCover)
        case toast(ToastType)
        case navigatablePath(NavigatablePath, resetStack: Bool = false)
    }

    private let logger = Logger(category: "Router")
    private let repository: Repository
    private var task: Task<Void, Never>?

    var path = [Screen]()
    var sheet: Sheet?
    var alert: AlertEvent?
    var fullScreenCover: FullScreenCover?
    var toast: ToastType?

    init(repository: Repository, path: [Screen] = [], sheet: Sheet? = nil) {
        self.repository = repository
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
        case let .toast(toast):
            self.toast = toast
        case let .navigatablePath(path, resetStack):
            guard task == nil else {
                logger.error("Trying to navigate too fast, previous navigatable path is still loading")
                return
            }
            task = Task {
                defer { task = nil }
                switch path {
                case let .product(id):
                    do {
                        let product = try await repository.product.getById(id: id)
                        self.open(.screen(.product(product), resetStack: resetStack))
                    } catch {
                        self.open(.screen(.error(reason: "Failed to load requested product page"),
                                          resetStack: resetStack))
                        logger.error("Request for product with \(id) failed. Error: \(error) (\(#file):\(#line))")
                    }
                case let .productWithBarcode(id, barcode):
                    do {
                        let product = try await repository.product.getById(id: id)
                        self.open(.screen(.productFromBarcode(product, barcode)))
                    } catch {
                        self.open(.screen(.error(reason: "Failed to load requested product page"),
                                          resetStack: resetStack))
                        logger.error("Request for product with \(id) failed. Error: \(error) (\(#file):\(#line))")
                    }
                case let .checkIn(id):
                    do {
                        let checkIn = try await repository.checkIn.getById(id: id)
                        self.open(.screen(.checkIn(checkIn), resetStack: resetStack))
                    } catch {
                        self.open(.screen(.error(reason: "Failed to load requested check-in page"),
                                          resetStack: resetStack))
                        logger.error("Request for check-in with \(id) failed. Error: \(error) (\(#file):\(#line))")
                    }
                case let .company(id):
                    do {
                        let company = try await repository.company.getById(id: id)
                        self.open(.screen(.company(company), resetStack: resetStack))
                    } catch {
                        self.open(.screen(.error(reason: "Failed to load requested company page"),
                                          resetStack: resetStack))
                        logger.error("Request for company with \(id) failed. Error: \(error) (\(#file):\(#line))")
                    }
                case let .brand(id):
                    do {
                        let brand = try await repository.brand.getJoinedById(id: id)
                        self.open(.screen(.brand(brand), resetStack: resetStack))
                    } catch {
                        self.open(.screen(.error(reason: "Failed to load requested company page"),
                                          resetStack: resetStack))
                        logger.error("Request for brand with \(id) failed. Error: \(error) (\(#file):\(#line))")
                    }
                case let .profile(id):
                    do {
                        let profile = try await repository.profile.getById(id: id)
                        self.open(.screen(.profile(profile), resetStack: resetStack))
                    } catch {
                        self.open(.screen(.error(reason: "Failed to load requested profile page"), resetStack: resetStack))
                        logger.error("Request for profile with \(id.uuidString.lowercased()) failed. error: \(error)")
                    }
                case let .location(id):
                    do {
                        let location = try await repository.location.getById(id: id)
                        self.open(.screen(.location(location), resetStack: resetStack))
                    } catch {
                        self.open(.screen(.error(reason: "Failed to load requested location page"),
                                          resetStack: resetStack))
                        logger.error("Request for location with \(id) failed. Error: \(error) (\(#file):\(#line))")
                    }
                }
            }
        }
    }

    func reset() {
        path = []
    }

    func removeLast() {
        path.removeLast()
    }
}
