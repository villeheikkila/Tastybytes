import Model
import SwiftUI

struct BrandShareLinkView: View {
    let brand: Brand.JoinedSubBrandsProductsCompany

    private var title: String {
        "\(brand.brandOwner.name): \(brand.name)"
    }

    var body: some View {
        ShareLink("Share", item: NavigatablePath.brand(id: brand.id).url, preview: SharePreview(title))
    }
}
