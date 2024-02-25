import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct DiscoverProductRow: View {
    private let logger = Logger(category: "DiscoverProductRow")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(Router.self) private var router
    @State private var sheet: Sheet?
    @State private var addBarcodeTo: Product.Joined?

    let product: Product.Joined
    @Binding var barcode: Barcode?

    var body: some View {
        ProductItemView(product: product, extras: [.checkInCheck, .rating, .logoOnLeft])
            .swipeActions {
                Button("checkIn.create.label", systemImage: "plus", action: { sheet = .newCheckIn(product, onCreation: { checkIn in
                    router.navigate(screen: .checkIn(checkIn))
                }) }).tint(.green)
            }
            .contentShape(Rectangle())
            .accessibilityAddTraits(.isLink)
            .onTapGesture {
                if barcode == nil || product.barcodes.contains(where: { $0.isBarcode(barcode) }) {
                    router.navigate(screen: .product(product))
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
            }
            .sheets(item: $sheet)
    }

    func addBarcodeToProduct(_ addBarcodeTo: Product.Joined) async {
        guard let barcode else { return }
        switch await repository.productBarcode.addToProduct(product: addBarcodeTo, barcode: barcode) {
        case .success:
            self.barcode = nil
            self.addBarcodeTo = nil
            feedbackEnvironmentModel.toggle(.success("checkIn.addBarcode.success.toast"))
            router.navigate(screen: .product(addBarcodeTo))
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Adding barcode \(barcode.barcode) to product \(addBarcodeTo.id) failed. error: \(error)")
        }
    }
}
