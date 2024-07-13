import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct BrandScreenProductRowView: View {
    private let logger = Logger(category: "BrandScreenProductRow")
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @State private var showDeleteProductConfirmationDialog = false
    @State private var productToDelete: Product.Joined?

    let product: Product.Joined

    var body: some View {
        RouterLink(open: .screen(.product(product))) {
            ProductEntityView(product: product, extras: [.logoOnLeft])
                .padding(2)
                .contextMenu {
                    RouterLink(open: .sheet(.duplicateProduct(
                        mode: profileEnvironmentModel
                            .hasPermission(.canMergeProducts) ? .mergeDuplicate : .reportDuplicate,
                        product: product
                    )), label: {
                        if profileEnvironmentModel.hasPermission(.canMergeProducts) {
                            Label("product.mergeTo.label", systemImage: "doc.on.doc")
                        } else {
                            Label("product.markAsDuplicate.label", systemImage: "doc.on.doc")
                        }
                    })

                    if profileEnvironmentModel.hasPermission(.canDeleteProducts) {
                        Button(
                            "labels.delete",
                            systemImage: "trash.fill",
                            role: .destructive,
                            action: { productToDelete = product }
                        )
                        .foregroundColor(.red)
                        .disabled(product.isVerified)
                    }
                }
        }
        .confirmationDialog("product.delete.confirmation.description",
                            isPresented: $productToDelete.isNotNull(),
                            titleVisibility: .visible,
                            presenting: productToDelete)
        { presenting in
            AsyncButton(
                "product.delete.confirmation.label \(presenting.formatted(.fullName))",
                role: .destructive,
                action: { await deleteProduct(presenting) }
            )
        }
        .alignmentGuide(.listRowSeparatorLeading) { _ in
            0
        }
    }

    private func deleteProduct(_ product: Product.Joined) async {
        do {
            try await repository.product.delete(id: product.id)
            feedbackEnvironmentModel.trigger(.notification(.success))
            router.removeLast()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete product \(product.id). Error: \(error) (\(#file):\(#line))")
        }
    }
}
