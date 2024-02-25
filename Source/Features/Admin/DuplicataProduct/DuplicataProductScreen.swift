import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct DuplicateProductScreen: View {
    private let logger = Logger(category: "ProductVerificationScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var products = [Product.Joined]()
    @State private var alertError: AlertError?
    @State private var deleteProduct: Product.Joined?

    var body: some View {
        List(products) { product in
            VStack {
                if let createdBy = product.createdBy {
                    HStack {
                        Avatar(profile: createdBy)
                            .avatarSize(.small)
                        Text(createdBy.preferredName).font(.caption).bold()
                        Spacer()
                        if let createdAt = product.createdAt {
                            Text(createdAt.formatted(.customRelativetime)).font(.caption).bold()
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
                        ProgressButton("labels.verify", systemImage: "checkmark", action: { await verifyProduct(product) })
                            .tint(.green)
                        RouterLink("labels.edit", systemImage: "pencil", sheet: .productEdit(product: product, onEdit: { _ in
                            await loadProducts()
                        })).tint(.yellow)
                        Button(
                            "labels.delete",
                            systemImage: "trash",
                            role: .destructive,
                            action: { deleteProduct = product }
                        )
                    }
            }
        }
        .listStyle(.plain)
        .alertError($alertError)
        .confirmationDialog("product.delete.confirmation.description",
                            isPresented: $deleteProduct.isNotNull(),
                            titleVisibility: .visible,
                            presenting: deleteProduct)
        { presenting in
            ProgressButton(
                "product.delete.confirmation.label \(presenting.formatted(.fullName))",
                role: .destructive,
                action: { await deleteProduct(presenting) }
            )
        }
        .navigationBarTitle("duplicateProducts.screen.title")
        .refreshable {
            await loadProducts(withHaptics: true)
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
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to verify product \(product.id). Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteProduct(_ product: Product.Joined) async {
        switch await repository.product.delete(id: product.id) {
        case .success:
            feedbackEnvironmentModel.trigger(.notification(.success))
            router.removeLast()
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete product \(product.id). Error: \(error) (\(#file):\(#line))")
        }
    }

    func loadProducts(withHaptics: Bool = false) async {
        if withHaptics {
            feedbackEnvironmentModel.trigger(.impact(intensity: .low))
        }
        switch await repository.product.getUnverified() {
        case let .success(products):
            withAnimation {
                self.products = products
            }
            if withHaptics {
                feedbackEnvironmentModel.trigger(.notification(.success))
            }

        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Fetching flavors failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
