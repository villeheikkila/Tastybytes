import Components

import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct BarcodeManagementScreen: View {
    private let logger = Logger(category: "BarcodeManagementScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackModel.self) private var feedbackModel
    @Environment(\.dismiss) private var dismiss

    @Binding var product: Product.Detailed

    var body: some View {
        List(product.barcodes) { barcode in
            BarcodeManagementRowView(barcode: barcode)
                .contextMenu {
                    DeleteButtonView(action: {
                        await deleteBarcode(barcode)
                    })
                    CopyToClipboardButtonView(content: barcode.barcode)
                    SearchGoogleLinkView(searchTerm: barcode.barcode)
                }
        }
        .listStyle(.plain)
        .overlay {
            if product.barcodes.isEmpty {
                ContentUnavailableView("barcode.management.empty.title", systemImage: "barcode")
            }
        }
        .navigationTitle("barcode.management.navigationTitle")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            RouterLink(
                "discover.barcode.scan",
                systemImage: "barcode.viewfinder",
                open: .sheet(.barcodeScanner(onComplete: { barcode in
                    await addBarcodeToProduct(product: product, barcode)
                }))
            )
        }
    }

    private func addBarcodeToProduct(product: Product.Detailed, _ barcode: Barcode) async {
        do {
            let new = try await repository.productBarcode.addToProduct(id: product.id, barcode: barcode)
            self.product = product.copyWith(barcodes: product.barcodes + [new])
        } catch {
            guard !error.isCancelled else { return }
            guard !error.isDuplicate else {
                router.open(.toast(.warning("barcode.duplicate.toast")))
                return
            }
            router.open(.alert(.init(title: "barcode.error.failedToAdd.title", retryLabel: "labels.retry", retry: {
                Task { await addBarcodeToProduct(product: product, barcode) }
            })))
            logger.error("Adding barcode \(barcode.barcode) to product failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteBarcode(_ barcode: Product.Barcode.JoinedWithCreator) async {
        do {
            try await repository.productBarcode.delete(id: barcode.id)
            let updated = product.barcodes.removing(barcode)
            product = product.copyWith(barcodes: updated)
            feedbackModel.trigger(.notification(.success))
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to fetch barcodes for product. Error: \(error) (\(#file):\(#line))")
        }
    }
}
