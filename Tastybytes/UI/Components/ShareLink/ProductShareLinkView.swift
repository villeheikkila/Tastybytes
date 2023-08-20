import Model
import SwiftUI

struct ProductShareLinkView: View {
    let product: Product.Joined

    private var title: String {
        product.getDisplayName(.fullName)
    }

    var body: some View {
        ShareLink("Share", item: NavigatablePath.product(id: product.id).url, preview: SharePreview(title))
    }
}
