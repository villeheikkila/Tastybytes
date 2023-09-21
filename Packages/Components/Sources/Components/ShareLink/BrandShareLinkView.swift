import Models
import SwiftUI

public struct BrandShareLinkView: View {
    let brand: Brand.JoinedSubBrandsProductsCompany

    public init(brand: Brand.JoinedSubBrandsProductsCompany) {
        self.brand = brand
    }

    private var title: String {
        "\(brand.brandOwner.name): \(brand.name)"
    }

    public var body: some View {
        ShareLink("Share", item: NavigatablePath.brand(id: brand.id).url, preview: SharePreview(title))
    }
}
