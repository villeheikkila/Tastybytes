import Components

import Models
import OSLog
import Repositories
import SwiftUI

struct ProductAdminSheet: View {
    typealias OnUpdateCallback = (Product.Detailed) async -> Void
    typealias OnDeleteCallback = (Product.Id) -> Void

    enum Open {
        case report(Report.Id)
        case editSuggestions(Product.EditSuggestion.Id)
    }

    let logger = Logger(category: "ProductAdminSheet")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackModel.self) private var feedbackModel
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var state: ScreenState = .loading
    @State private var product = Product.Detailed()

    @State private var id: Product.Id
    @State private var open: Open?
    private let onUpdate: OnUpdateCallback
    private let onDelete: OnDeleteCallback

    init(
        id: Product.Id,
        open: Open?,
        onUpdate: @escaping OnUpdateCallback,
        onDelete: @escaping OnDeleteCallback
    ) {
        _id = State(initialValue: id)
        _open = State(initialValue: open)
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }

    var body: some View {
        List {
            if state.isPopulated {
                content
            }
        }
        .refreshable {
            await initialize(id: id)
        }
        .scrollContentBackground(.hidden)
        .animation(.default, value: product)
        .overlay {
            ScreenStateOverlayView(state: state) {
                await initialize(id: id)
            }
        }
        .navigationTitle("product.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .initialTask(id: id) {
            await initialize(id: id)
        }
    }

    @ViewBuilder private var content: some View {
        Section("product.admin.section.product") {
            RouterLink(open: .screen(.product(product.id))) {
                ProductEntityView(product: .init(product: product))
            }
            .buttonStyle(.plain)
        }
        .customListRowBackground()
        ModificationInfoView(modificationInfo: product)
        Section("admin.section.details") {
            LabeledIdView(id: product.id.rawValue.formatted())
            LabeledContent("subBrand.label") {
                RouterLink(product.subBrand.name ?? "-",
                           open: .sheet(.subBrandAdmin(id: product.subBrand.id, onUpdate: { subBrand in
                               product = product.copyWith(subBrand: .init(subBrand: subBrand))
                               await onUpdate(product)
                           })))
            }
            LabeledContent("brand.label") {
                RouterLink(product.subBrand.brand.name,
                           open: .sheet(.brandAdmin(id: product.subBrand.brand.id, onUpdate: { brand in
                               product = product.copyWith(subBrand: product.subBrand.copyWith(brand: .init(brand: brand)))
                               await onUpdate(product)
                           })))
            }
            LabeledContent("brandOwner.label") {
                RouterLink(
                    product.subBrand.brand.brandOwner.name,
                    open: .sheet(
                        .companyAdmin(
                            id: product.subBrand.brand.brandOwner.id,
                            onUpdate: { company in
                                product = product
                                    .copyWith(
                                        subBrand: product.subBrand
                                            .copyWith(brand: product.subBrand.brand.copyWith(brandOwner: .init(company: company)))
                                    )
                                await onUpdate(product)
                            }
                        )
                    )
                )
            }
            VerificationAdminToggleView(isVerified: product.isVerified, action: { isVerified in
                await verifyProduct(id: id, isVerified: isVerified)
            })
        }
        .customListRowBackground()
        EditLogoSectionView(logos: product.logos, onUpload: { data in
            await uploadData(id: id, data: data)
        }, onDelete: { entity in
            await deleteLogo(id: id, entity: entity)
        })
        Section("admin.section.contributions.label") {
            RouterLink(
                "barcode.management.open",
                systemImage: "barcode",
                count: product.barcodes.count,
                open: .screen(.barcodeManagement(product: $product))
            )
            RouterLink(
                "product.admin.variants.navigationTitle",
                systemImage: "square.stack",
                count: product.variants.count,
                open: .screen(.productVariants(variants: product.variants))
            )
            RouterLink(
                "admin.section.editSuggestions.title",
                systemImage: "pencil",
                badge: product.editSuggestions.unresolvedCount,
                open: .screen(.productEditSuggestion(product: $product))
            )
            RouterLink(
                "admin.section.reports.title",
                systemImage: "exclamationmark.bubble",
                badge: product.reports.count,
                open: .screen(
                    .reports(reports: $product.map(getter: { location in
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
        }
        .buttonStyle(.plain)
        .customListRowBackground()

        Section {
            MergeProductsButtonView(product: product, onMerge: mergeProducts)
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

    private func initialize(id: Product.Id) async {
        do {
            let product = try await repository.product.getDetailed(id: id)
            self.product = product
            state = .populated

            if let open {
                switch open {
                case let .report(id):
                    router.open(.screen(
                        .reports(reports: $product.map(getter: { location in
                            location.reports
                        }, setter: { reports in
                            product.copyWith(reports: reports)
                        }), initialReport: id)))
                case let .editSuggestions(id):
                    router.open(.screen(.productEditSuggestion(product: $product, initialEditSuggestion: id)))
                }
                self.open = nil
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .error(error)
            logger.error("Failed to load detailed product. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func verifyProduct(id: Product.Id, isVerified: Bool) async {
        do {
            try await repository.product.verification(id: id, isVerified: isVerified)
            feedbackModel.trigger(.notification(.success))
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
            feedbackModel.trigger(.notification(.success))
            onDelete(product.id)
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete product. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteLogo(id: Product.Id, entity: ImageEntity.Saved) async {
        do {
            try await repository.imageEntity.delete(from: .productLogos, id: entity.id)
            product = product.copyWith(logos: product.logos.removing(entity))
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete image. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func uploadData(id: Product.Id, data: Data) async {
        do {
            let imageEntity = try await repository.product.uploadLogo(productId: id, data: data)
            product = product.copyWith(logos: product.logos + [imageEntity])
            logger.info("Succesfully uploaded logo \(imageEntity.file)")
        } catch {
            logger.error("Uploading of a product logo failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func mergeProducts(id: Product.Id, _ mergeToId: Product.Id) async {
        do {
            try await repository.product.mergeProducts(id: id, toProductId: mergeToId)
            self.id = mergeToId
            feedbackModel.trigger(.notification(.success))
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Merging product \(product.id) to \(id) failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct MergeProductsButtonView: View {
    @State private var mergeToProduct: Product.Joined?

    let product: Product.Detailed
    let onMerge: (_ id: Product.Id, _ mergeTo: Product.Id) async -> Void

    var body: some View {
        RouterLink(
            "product.admin.mergeProducts.label",
            systemImage: "arrow.triangle.merge",
            open: .sheet(.productPicker(product: $mergeToProduct))
        )
        .foregroundColor(.primary)
        .confirmationDialog(
            "product.admin.mergeProducts.description",
            isPresented: $mergeToProduct.isNotNull(),
            titleVisibility: .visible,
            presenting: mergeToProduct
        ) { presenting in
            AsyncButton(
                "product.admin.mergeProducts.apply \(product.name ?? "-") \(presenting.name ?? "-")",
                action: {
                    await onMerge(product.id, presenting.id)
                }
            )
            .tint(.green)
        }
    }
}
