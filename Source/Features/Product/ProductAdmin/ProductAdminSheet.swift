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
    @State private var state: ScreenState = .loading
    @State private var showDeleteProductConfirmationDialog = false
    @State private var logos: [ImageEntity] = []
    @State private var product = Product.Detailed()

    let id: Product.Id
    let onDelete: () -> Void
    let onUpdate: () async -> Void

    var body: some View {
        List {
            if state.isPopulated {
                content
            }
        }
        .scrollContentBackground(.hidden)
        .animation(.default, value: product)
        .overlay {
            ScreenStateOverlayView(state: state, errorAction: loadData)
        }
        .navigationTitle("product.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .initialTask {
            await loadData()
        }
    }

    @ViewBuilder private var content: some View {
        Section("product.admin.section.product") {
            RouterLink(open: .screen(.product(.init(product: product)))) {
                ProductEntityView(product: product)
            }
            .buttonStyle(.plain)
        }
        .customListRowBackground()
        ModificationInfoView(modificationInfo: product)
        Section("admin.section.details") {
            LabeledIdView(id: product.id.rawValue.formatted())
            VerificationAdminToggleView(isVerified: product.isVerified, action: verifyProduct)
        }
        .customListRowBackground()
        EditLogoSection(logos: logos, onUpload: uploadData, onDelete: deleteLogo)
        Section("admin.section.contributions.label") {
            RouterLink(
                "barcode.management.open",
                systemImage: "barcode",
                count: product.barcodes.count,
                open: .screen(.barcodeManagement(product: $product))
            )
            RouterLink(
                "admin.section.editSuggestions.title",
                systemImage: "pencil",
                count: product.editSuggestions.unresolvedCount,
                open: .screen(.productEditSuggestion(product: $product))
            )
            RouterLink(
                "product.admin.variants.navigationTitle",
                systemImage: "square.stack",
                count: product.variants.count,
                open: .screen(.productVariants(variants: product.variants))
            )
            RouterLink(
                "admin.section.reports.title",
                systemImage: "exclamationmark.bubble",
                count: product.reports.count,
                open: .screen(
                    .withReportsAdmin(reports: $product.map(getter: { location in
                        location.reports
                    }, setter: { reports in
                        product.copyWith(reports: reports)
                    }))
                )
            )
        }
        .buttonStyle(.plain)
        .customListRowBackground()

        Section {
            RouterLink("labels.edit", systemImage: "pencil", open: .sheet(.product(.edit(.init(product: product), onEdit: { updatedProduct in
                product = product.mergeWith(product: updatedProduct)
            }))))
            RouterLink("product.mergeTo.label", systemImage: "doc.on.doc", open: .sheet(.duplicateProduct(mode: .mergeDuplicate, product: .init(product: product))))
        }
        .buttonStyle(.plain)
        .customListRowBackground()

        Section {
            ConfirmedDeleteButtonView(
                presenting: product,
                action: deleteProduct,
                description: "product.delete.confirmation.description",
                label: "product.delete.confirmation.label \(product.formatted(.fullName))",
                isDisabled: product.isVerified
            )
        }
        .customListRowBackground()
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    private func loadData() async {
        do {
            let product = try await repository.product.getDetailed(id: id)
            withAnimation {
                self.product = product
                state = .populated
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed to load detailed product. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func verifyProduct(isVerified: Bool) async {
        do {
            try await repository.product.verification(id: id, isVerified: isVerified)
            feedbackEnvironmentModel.trigger(.notification(.success))
            product = product.copyWith(isVerified: isVerified)
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to verify product. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteProduct(_ product: Product.Detailed) async {
        do {
            try await repository.product.delete(id: product.id)
            feedbackEnvironmentModel.trigger(.notification(.success))
            onDelete()
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete product. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteLogo(entity: ImageEntity) async {
        do {
            try await repository.imageEntity.delete(from: .productLogos, entity: entity)
            withAnimation {
                logos.remove(object: entity)
            }
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func uploadData(data: Data) async {
        do {
            let imageEntity = try await repository.product.uploadLogo(productId: id, data: data)
            logos.append(imageEntity)
            logger.info("Succesfully uploaded logo \(imageEntity.file)")
        } catch {
            logger.error("Uploading of a product logo failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct ProductVariantsScreen: View {
    let variants: [Product.Variant]

    var body: some View {
        List(variants) { variant in
            Text(variant.id.rawValue.formatted())
        }
        .navigationTitle("product.admin.variants.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
