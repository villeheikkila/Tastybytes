import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct BrandScreenProductRow: View {
    private let logger = Logger(category: "BrandScreenProductRow")
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(\.repository) private var repository
    @Environment(Router.self) private var router
    @State private var alertError: AlertError?
    @State private var showDeleteProductConfirmationDialog = false
    @State private var productToDelete: Product.Joined? {
        didSet {
            if productToDelete != nil {
                showDeleteProductConfirmationDialog = true
            }
        }
    }

    let product: Product.Joined

    var body: some View {
        RouterLink(screen: .product(product)) {
            ProductItemView(product: product)
                .padding(2)
                .contextMenu {
                    RouterLink(sheet: .duplicateProduct(
                        mode: profileEnvironmentModel
                            .hasPermission(.canMergeProducts) ? .mergeDuplicate : .reportDuplicate,
                        product: product
                    ), label: {
                        if profileEnvironmentModel.hasPermission(.canMergeProducts) {
                            Label("Merge to...", systemImage: "doc.on.doc")
                        } else {
                            Label("Mark as Duplicate", systemImage: "doc.on.doc")
                        }
                    })

                    if profileEnvironmentModel.hasPermission(.canDeleteProducts) {
                        Button(
                            "Delete",
                            systemImage: "trash.fill",
                            role: .destructive,
                            action: { productToDelete = product }
                        )
                        .foregroundColor(.red)
                        .disabled(product.isVerified)
                    }
                }
        }
        .confirmationDialog("Are you sure you want to delete the product and all of its check-ins?",
                            isPresented: $showDeleteProductConfirmationDialog,
                            titleVisibility: .visible,
                            presenting: productToDelete)
        { presenting in
            ProgressButton(
                "Delete \(presenting.getDisplayName(.fullName))",
                role: .destructive,
                action: { await deleteProduct(presenting) }
            )
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
}