import SwiftUI

struct BarcodeManagementContentUnavailable: View {
    private var title: String {
        "No barcodes have been added"
    }

    private var systemImage: String {
        "barcode"
    }

    var body: some View {
        ContentUnavailableView(title, systemImage: systemImage)
    }
}
