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
            BarcodeManagementRowView(barcode: barcode)
                .swipeActions {
                    DeleteButtonView(action: {
                        await deleteBarcode(barcode)
                    })
                }
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
            if state == .populated {
                if barcodes.isEmpty {
                    ContentUnavailableView("No barcodes have been added", systemImage: "barcode")
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

    private func deleteBarcode(_ barcode: ProductBarcode.JoinedWithCreator) async {
        do {
            try await repository.productBarcode.delete(id: barcode.id)
            withAnimation {
                barcodes.remove(object: barcode)
            }
            feedbackEnvironmentModel.trigger(.notification(.success))
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to fetch barcodes for product. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func getBarcodes() async {
        do {
            let barcodes = try await repository.productBarcode.getByProductId(id: product.id)
            withAnimation {
                self.barcodes = barcodes
                state = .populated
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed to fetch barcodes for product. Error: \(error) (\(#file):\(#line))")
        }
    }
}
