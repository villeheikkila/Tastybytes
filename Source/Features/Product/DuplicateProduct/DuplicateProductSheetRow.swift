import Components
import Models
import SwiftUI

struct DuplicateProductSheetRow: View {
    @State private var showMergeToProductConfirmationDialog = false
    let product: Product.Joined
    let mode: ProductDuplicateScreen.Mode
    let onAction: (_ product: Product.Joined) async -> Void

    var body: some View {
        Button(action: { showMergeToProductConfirmationDialog = true }, label: {
            HStack {
                ProductEntityView(product: product)
                Spacer()
            }
            .contentShape(.rect)
        })
        .buttonStyle(.plain)
        .listRowBackground(Color.clear)
        .confirmationDialog("duplicateProduct.mergeTo.description",
                            isPresented: $showMergeToProductConfirmationDialog,
                            presenting: product)
        { presenting in
            ProgressButton(
                mode == .mergeDuplicate ? "duplicateProduct.mergeDuplicates.label \(product.formatted(.fullName)) \(presenting.formatted(.fullName))" : "duplicateProduct.markAsDuplicate.label \(product.formatted(.fullName)) \(presenting.formatted(.fullName))",
                role: .destructive
            ) {
                await onAction(product)
            }
        }
    }
}
