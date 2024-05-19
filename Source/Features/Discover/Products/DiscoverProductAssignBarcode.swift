import Models
import SwiftUI

@MainActor
struct DiscoverProductAssignBarcode: View {
    let isEmpty: Bool
    @Binding var barcode: Barcode?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(isEmpty ? "discover.barcode.noResults.description" : "discover.barcode.results.description")
            Button("discover.barcode.dismiss.label", action: {
                barcode = nil
            })
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
        }
        .padding()
        .background(.thinMaterial)
    }
}
