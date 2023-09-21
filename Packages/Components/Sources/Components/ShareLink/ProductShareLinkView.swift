import Models
import SwiftUI

public struct ProductShareLinkView: View {
    let product: Product.Joined

    public init(product: Product.Joined) {
        self.product = product
    }

    private var title: String {
        product.getDisplayName(.fullName)
    }

    public var body: some View {
        ShareLink("Share", item: NavigatablePath.product(id: product.id).url, preview: SharePreview(title))
    }
}
