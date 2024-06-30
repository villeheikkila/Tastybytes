import EnvironmentModels
import Models
import SwiftUI

public struct ProductShareLinkView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let product: Product.Joined

    public init(product: Product.Joined) {
        self.product = product
    }

    private var title: String {
        product.formatted(.fullName)
    }

    private var link: URL {
        NavigatablePath.product(id: product.id).getUrl(baseUrl: appEnvironmentModel.infoPlist.baseUrl)
    }

    public var body: some View {
        ShareLink(item: link, subject: Text("product.shareLink.subject"), message: Text(title))
    }
}
