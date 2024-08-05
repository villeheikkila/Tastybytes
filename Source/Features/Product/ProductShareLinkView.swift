
import Models
import SwiftUI

public struct ProductShareLinkView: View {
    @Environment(AppModel.self) private var appModel
    let product: Product.Joined

    public init(product: Product.Joined) {
        self.product = product
    }

    private var title: String {
        product.formatted(.fullName)
    }

    private var link: URL {
        NavigatablePath.product(id: product.id).getUrl(baseUrl: appModel.infoPlist.baseUrl)
    }

    public var body: some View {
        ShareLink(item: link, subject: Text("product.shareLink.subject"), message: Text(title))
    }
}
