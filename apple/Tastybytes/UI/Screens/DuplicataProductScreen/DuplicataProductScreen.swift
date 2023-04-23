import SwiftUI

struct DuplicateProductScreen: View {
  private let logger = getLogger(category: "ProductVerificationScreen")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @State private var products = [Product.Joined]()
  @State private var deleteProduct: Product.Joined? {
    didSet {
      showDeleteProductConfirmationDialog = true
    }
  }

  @State private var showDeleteProductConfirmationDialog = false

  var body: some View {
    List {
      ForEach(products) { product in
        VStack {
          if let createdBy = product.createdBy {
            HStack {
              AvatarView(avatarUrl: createdBy.avatarUrl, size: 16, id: createdBy.id)
              Text(createdBy.preferredName).font(.caption).bold()
              Spacer()
              if let createdAt = product.createdAt, let date = Date(timestamptzString: createdAt) {
                Text(date.customFormat(.relativeTime)).font(.caption).bold()
              }
            }
          }
          ProductItemView(product: product)
            .contentShape(Rectangle())
            .accessibilityAddTraits(.isLink)
            .onTapGesture {
              router.navigate(screen: .product(product))
            }
            .swipeActions {
              ProgressButton("Verify", systemImage: "checkmark", action: { await verifyProduct(product) }).tint(.green)
              RouterLink("Edit", systemImage: "pencil", sheet: .editProduct(product: product, onEdit: {
                await loadProducts()
              })).tint(.yellow)
              Button("Delete", systemImage: "trash", role: .destructive, action: { deleteProduct = product })
            }
        }
      }
    }
    .listStyle(.plain)
    .confirmationDialog("Are you sure you want to delete the product and all of its check-ins?",
                        isPresented: $showDeleteProductConfirmationDialog,
                        titleVisibility: .visible,
                        presenting: deleteProduct)
    { presenting in
      ProgressButton(
        "Delete \(presenting.getDisplayName(.fullName))",
        role: .destructive,
        action: { await deleteProduct(presenting) }
      )
    }
    .navigationBarTitle("Unverified Products")
    .refreshable {
      await feedbackManager.wrapWithHaptics {
        await loadProducts()
      }
    }
    .task {
      await loadProducts()
    }
  }

  func verifyProduct(_ product: Product.Joined) async {
    switch await repository.product.verification(id: product.id, isVerified: true) {
    case .success:
      withAnimation {
        products.remove(object: product)
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to verify product \(product.id): \(error.localizedDescription)")
    }
  }

  func deleteProduct(_ product: Product.Joined) async {
    switch await repository.product.delete(id: product.id) {
    case .success:
      feedbackManager.trigger(.notification(.success))
      router.removeLast()
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to delete product \(product.id): \(error.localizedDescription)")
    }
  }

  func loadProducts() async {
    switch await repository.product.getUnverified() {
    case let .success(products):
      withAnimation {
        self.products = products
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("fetching flavors failed: \(error.localizedDescription)")
    }
  }
}
