import Components

import Models
import OSLog
import Repositories
import SwiftUI

struct DiscoverProductRow: View {
    private let logger = Logger(category: "DiscoverProductRow")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @State private var showAddBarcodeToConfirmationDialog = false

    let product: Product.Joined
    @Binding var barcode: Barcode?

    var body: some View {
        ProductView(product: product)
            .productLogoLocation(.left)
            .swipeActions {
                RouterLink("checkIn.create.label", systemImage: "plus", open: .sheet(.checkIn(.create(product: product, onCreation: { checkIn in
                    router.open(.screen(.checkIn(checkIn.id)))
                })))).tint(.green)
            }
            .contentShape(.rect)
            .accessibilityAddTraits(.isLink)
            .onTapGesture {
                if barcode == nil || (product.barcodes ?? []).contains(where: { $0.isSameAs(barcode) }) {
                    router.open(.screen(.product(product.id)))
                } else {
                    showAddBarcodeToConfirmationDialog = true
                }
            }
            .confirmationDialog(
                "checkIn.addBarcode.confirmation.title",
                isPresented: $showAddBarcodeToConfirmationDialog,
                presenting: product
            ) { presenting in
                AsyncButton(
                    "checkIn.addBarcode.label \(presenting.formatted(.fullName))",
                    action: {
                        await addBarcodeToProduct(presenting)
                    }
                )
                Button(
                    "checkIn.discardBarcode.label",
                    role: .destructive,
                    action: {
                        barcode = nil
                    }
                )
            }
    }

    private func addBarcodeToProduct(_ addBarcodeTo: Product.Joined) async {
        guard let barcode else { return }
        do {
            try await repository.productBarcode.addToProduct(id: addBarcodeTo.id, barcode: barcode)
            self.barcode = nil
            router.open(.toast(.success("checkIn.addBarcode.success.toast")))
            router.open(.screen(.product(addBarcodeTo.id)))
        } catch {
            guard !error.isCancelled else { return }
            guard !error.isDuplicate else {
                router.open(.toast(.warning("barcode.duplicate.toast")))
                return
            }
            logger.error("Adding barcode \(barcode.barcode) to product \(addBarcodeTo.id) failed. error: \(error)")
        }
    }
}
