import SwiftUI

@MainActor
final class SheetManager: ObservableObject {
  private let logger = getLogger(category: "SheetManager")
  @Published var sheet: Sheet?
  @Published var nestedSheet: Sheet?

  func navigate(sheet: Sheet) {
    if self.sheet != nil, nestedSheet != nil {
      logger.error("opening more than one nested sheet is not supported")
      return
    }
    if self.sheet != nil {
      nestedSheet = sheet
    } else {
      self.sheet = sheet
    }
  }
}

@MainActor
final class Router: ObservableObject {
  private let logger = getLogger(category: "Router")
  @Published var path: [Screen] = []

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

  func fetchAndNavigateTo(_ repository: Repository, _ destination: NavigatablePath, resetStack: Bool = false) {
    Task {
      switch destination {
      case let .product(id):
        switch await repository.product.getById(id: id) {
        case let .success(product):
          self.navigate(screen: .product(product), resetStack: resetStack)
        case let .failure(error):
          self.navigate(screen: .error(reason: "Failed to load requested product page"), resetStack: resetStack)
          logger.error("request for product with \(id) failed: \(error.localizedDescription)")
        }
      case let .checkIn(id):
        switch await repository.checkIn.getById(id: id) {
        case let .success(checkIn):
          self.navigate(screen: .checkIn(checkIn), resetStack: resetStack)
        case let .failure(error):
          self.navigate(screen: .error(reason: "Failed to load requested check-in page"), resetStack: resetStack)
          logger.error("request for check-in with \(id) failed: \(error.localizedDescription)")
        }
      case let .company(id):
        switch await repository.company.getById(id: id) {
        case let .success(company):
          self.navigate(screen: .company(company), resetStack: resetStack)
        case let .failure(error):
          self.navigate(screen: .error(reason: "Failed to load requested company page"), resetStack: resetStack)
          logger.error("request for company with \(id) failed: \(error.localizedDescription)")
        }
      case let .brand(id):
        switch await repository.brand.getJoinedById(id: id) {
        case let .success(brand):
          self.navigate(screen: .brand(brand), resetStack: resetStack)
        case let .failure(error):
          self.navigate(screen: .error(reason: "Failed to load requested company page"), resetStack: resetStack)
          logger.error("request for brand with \(id) failed: \(error.localizedDescription)")
        }
      case let .profile(id):
        switch await repository.profile.getById(id: id) {
        case let .success(profile):
          self.navigate(screen: .profile(profile), resetStack: resetStack)
        case let .failure(error):
          self.navigate(screen: .error(reason: "Failed to load requested profile page"), resetStack: resetStack)
          logger.error("request for profile with \(id.uuidString.lowercased()) failed: \(error.localizedDescription)")
        }
      case let .location(id):
        switch await repository.location.getById(id: id) {
        case let .success(location):
          self.navigate(screen: .location(location), resetStack: resetStack)
        case let .failure(error):
          self.navigate(screen: .error(reason: "Failed to load requested location page"), resetStack: resetStack)
          logger.error("request for location with \(id) failed: \(error.localizedDescription)")
        }
      }
    }
  }
}
