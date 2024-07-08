import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct BarcodeManagementScreen: View {
    private let logger = Logger(category: "BarcodeManagementScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var state: ScreenState = .loading
    @State private var barcodes: [ProductBarcode.JoinedWithCreator] = []

    let product: Product.Joined

    var body: some View {
        List(barcodes) { barcode in
            BarcodeManagementRow(barcode: barcode)
                .swipeActions {
                    DeleteButton(action: {
                        await deleteBarcode(barcode)
                    })
                }
                .contextMenu {
                    DeleteButton(action: {
                        await deleteBarcode(barcode)
                    })
                    CopyToClipboardButton(content: barcode.barcode)
                    SearchGoogleLink(searchTerm: barcode.barcode)
                }
        }
        .listStyle(.plain)
        .overlay {
            if state == .populated {
                if barcodes.isEmpty {
                    BarcodeManagementContentUnavailable()
                }
            } else {
                ScreenStateOverlayView(state: state, errorDescription: "") {
                    await getBarcodes()
                }
            }
        }
        .task {
            await getBarcodes()
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
                open: .sheet(.barcodeScanner(onComplete: { _ in
                    await getBarcodes()
                }))
            )
        }
    }

    func deleteBarcode(_ barcode: ProductBarcode.JoinedWithCreator) async {
        switch await repository.productBarcode.delete(id: barcode.id) {
        case .success:
            withAnimation {
                barcodes.remove(object: barcode)
            }
            feedbackEnvironmentModel.trigger(.notification(.success))
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to fetch barcodes for product. Error: \(error) (\(#file):\(#line))")
        }
    }

    func getBarcodes() async {
        switch await repository.productBarcode.getByProductId(id: product.id) {
        case let .success(barcodes):
            withAnimation {
                self.barcodes = barcodes
                state = .populated
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed to fetch barcodes for product. Error: \(error) (\(#file):\(#line))")
        }
    }
}
