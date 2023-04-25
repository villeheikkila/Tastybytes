import RevenueCat
import SwiftUI

@MainActor
final class PurchaseManager: ObservableObject {
  @Published var customerInfo: CustomerInfo?
  @Published var subscription: StoreProduct?
  @Published var isLoading = false

  let feedbackManager: FeedbackManager

  init(feedbackManager: FeedbackManager) {
    self.feedbackManager = feedbackManager
  }

  var isSupporter: Bool {
    customerInfo?.entitlements[PurchaseType.supporter.rawValue]?.isActive ?? false
  }

  func initialize() {
    Purchases.shared.getProducts(PurchaseType.allCases.map(\.rawValue)) { products in
      self.subscription = products.first(where: { $0.productIdentifier == PurchaseType.supporter.rawValue })
    }
  }

  func refreshUserInfo() {
    Purchases.shared.getCustomerInfo { info, _ in
      self.customerInfo = info
    }
  }

  func purchase(product: StoreProduct) async {
    guard !isLoading else { return }
    isLoading = true
    do {
      let result = try await Purchases.shared.purchase(product: product)
      if !result.userCancelled {
        feedbackManager.toggle(.success("Thanks for the tip!"))
      }
    } catch {
      feedbackManager.toggle(.error(.unexpected))
    }
    isLoading = false
  }
}

enum PurchaseType: String, CaseIterable {
  case supporter

  var title: String {
    switch self {
    case .supporter:
      return "Supporter"
    }
  }

  var actionLabel: String {
    switch self {
    case .supporter:
      return "Become a supporter"
    }
  }

  var description: String {
    switch self {
    case .supporter:
      return "Help the development of \(Config.appName) by becoming a supporter and gain access to extra features!"
    }
  }
}
