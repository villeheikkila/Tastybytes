import Models
import SwiftUI

@MainActor
struct DiscoverProductAssignBarcode: View {
    let isEmpty: Bool
    @Binding var barcode: Barcode?

    var body: some View {
        Section {
            Text(isEmpty ? "discover.barcode.noResults.description" : "discover.barcode.results.description")
            Button("discover.barcode.dismiss.label", action: {
                barcode = nil
            })
        }
    }
}
