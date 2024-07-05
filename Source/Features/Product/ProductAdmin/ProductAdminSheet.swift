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
    @State private var showDeleteProductConfirmationDialog = false
    @Binding var product: Product.Joined

    var body: some View {
        List {
            Section {
                RouterLink(open: .screen(.product(product))) {
                    ProductEntityView(product: product)
                }
            }

            Section {
                LabeledContent("labels.id", value: product.id.formatted())
                LabeledContent("verification.verified.label", value: "\(product.isVerified)".capitalized)
            }

            Section {
                RouterLink("barcode.management.open", systemImage: "barcode", open: .sheet(.barcodeManagement(product: product)))
                RouterLink("labels.edit", systemImage: "pencil", open: .sheet(.product(.edit(product, onEdit: { updatedProduct in
                    withAnimation {
                        product = updatedProduct
                    }
                }))))
                RouterLink("product.mergeTo.label", systemImage: "doc.on.doc", open: .sheet(.duplicateProduct(mode: .mergeDuplicate, product: product)))
                RouterLink("admin.section.reports.title", systemImage: "exclamationmark.bubble", open: .screen(.reports(.product(product.id))))
                    .foregroundColor(.accent)
            }

            Section {
                Button(
                    "labels.delete",
                    systemImage: "trash.fill",
                    role: .destructive,
                    action: { showDeleteProductConfirmationDialog = true }
                )
                .foregroundColor(.red)
                .disabled(product.isVerified)
                .confirmationDialog("product.delete.confirmation.description",
                                    isPresented: $showDeleteProductConfirmationDialog,
                                    titleVisibility: .visible,
                                    presenting: product)
                { presenting in
                    ProgressButton(
                        "product.delete.confirmation.label \(presenting.formatted(.fullName))",
                        role: .destructive,
                        action: { await deleteProduct(presenting) }
                    )
                }
            }
        }
        .navigationTitle("product.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarDismissAction()
        }
    }

    func deleteProduct(_ product: Product.Joined) async {
        switch await repository.product.delete(id: product.id) {
        case .success:
            feedbackEnvironmentModel.trigger(.notification(.success))
            router.removeLast()
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete product. Error: \(error) (\(#file):\(#line))")
        }
    }
}
