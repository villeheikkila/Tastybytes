import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct DiscoverProductRow: View {
    private let logger = Logger(category: "DiscoverProductRow")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(Router.self) private var router
    @State private var addBarcodeTo: Product.Joined?

    let product: Product.Joined
    @Binding var barcode: Barcode?

    var body: some View {
        ProductItemView(product: product, extras: [.checkInCheck, .rating, .logoOnLeft])
            .swipeActions {
                RouterLink("checkIn.create.label", systemImage: "plus", open: .sheet(.checkIn(.create(product: product, onCreation: { checkIn in
                    router.open(.screen(.checkIn(checkIn)))
                })))).tint(.green)
            }
            .contentShape(Rectangle())
            .accessibilityAddTraits(.isLink)
            .onTapGesture {
                if barcode == nil || product.barcodes.contains(where: { $0.isBarcode(barcode) }) {
                    router.open(.screen(.product(product)))
                } else {
                    addBarcodeTo = product
                }
            }
            .confirmationDialog(
                "checkIn.addBarcode.confirmation.title",
                isPresented: $addBarcodeTo.isNotNull(),
                presenting: addBarcodeTo
            ) { presenting in
                ProgressButton(
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

    func addBarcodeToProduct(_ addBarcodeTo: Product.Joined) async {
        guard let barcode else { return }
        switch await repository.productBarcode.addToProduct(product: addBarcodeTo, barcode: barcode) {
        case .success:
            self.barcode = nil
            self.addBarcodeTo = nil
            router.open(.toast(.success("checkIn.addBarcode.success.toast")))
            router.open(.screen(.product(addBarcodeTo)))
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Adding barcode \(barcode.barcode) to product \(addBarcodeTo.id) failed. error: \(error)")
        }
    }
}
