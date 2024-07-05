import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct ProductAdminSheet: View {
    let logger = Logger(category: "ProductAdminSheet")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteProductConfirmationDialog = false
    @Binding var product: Product.Joined

    let onDelete: () -> Void

    var body: some View {
        List {
            Section("product.admin.section.product") {
                RouterLink(open: .screen(.product(product))) {
                    ProductEntityView(product: product)
                }
            }

            CreationInfoSection(createdBy: product.createdBy, createdAt: product.createdAt)

            Section("admin.section.details") {
                LabeledContent("labels.id", value: product.id.formatted())
                    .textSelection(.enabled)
                    .multilineTextAlignment(.trailing)
                VerificationAdminToggleView(isVerified: product.isVerified) { isVerified in
                    await verifyProduct(isVerified: isVerified)
                }
            }

            Section {
                RouterLink("barcode.management.open", systemImage: "barcode", open: .sheet(.barcodeManagement(product: product)))
                RouterLink("labels.edit", systemImage: "pencil", open: .sheet(.product(.edit(product, onEdit: { updatedProduct in
                    withAnimation {
                        product = updatedProduct
                    }
                }))))
                RouterLink("product.mergeTo.label", systemImage: "doc.on.doc", open: .sheet(.duplicateProduct(mode: .mergeDuplicate, product: product)))
                RouterLink("admin.duplicates.title", systemImage: "plus.square.on.square", open: .screen(.duplicateProducts(filter: .id(product.id))))
                RouterLink("admin.section.reports.title", systemImage: "exclamationmark.bubble", open: .screen(.reports(.product(product.id))))
                    .foregroundColor(.accent)
            }

            ConfirmedDeleteButtonView(
                presenting: product,
                action: deleteProduct,
                description: "product.delete.confirmation.description",
                label: "product.delete.confirmation.label \(product.formatted(.fullName))",
                isDisabled: product.isVerified
            )
        }
        .navigationTitle("product.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarDismissAction()
        }
        .initialTask {
            await loadData()
        }
    }

    func loadData() async {
        switch await repository.product.getDetailed(id: product.id) {
        case let .success(product):
            withAnimation {
                self.product = product
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Failed to load detailed product. Error: \(error) (\(#file):\(#line))")
        }
    }

    func verifyProduct(isVerified: Bool) async {
        switch await repository.product.verification(id: product.id, isVerified: isVerified) {
        case .success:
            feedbackEnvironmentModel.trigger(.notification(.success))
            product = product.copyWith(isVerified: isVerified)
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to verify product. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteProduct(_ product: Product.Joined) async {
        switch await repository.product.delete(id: product.id) {
        case .success:
            feedbackEnvironmentModel.trigger(.notification(.success))
            onDelete()
            dismiss()
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete product. Error: \(error) (\(#file):\(#line))")
        }
    }
}
