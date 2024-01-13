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
        product.getDisplayName(.fullName)
    }

    public var body: some View {
        ShareLink("Share", item: NavigatablePath.product(id: product.id).getUrl(baseUrl: appEnvironmentModel.infoPlist.baseUrl), preview: SharePreview(title))
    }
}
