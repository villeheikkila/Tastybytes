import EnvironmentModels
import Models
import SwiftUI

public struct BrandShareLinkView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let brand: Brand.JoinedSubBrandsProductsCompany

    public init(brand: Brand.JoinedSubBrandsProductsCompany) {
        self.brand = brand
    }

    private var title: String {
        "\(brand.brandOwner.name): \(brand.name)"
    }

    public var body: some View {
        ShareLink("Share", item: NavigatablePath.brand(id: brand.id).getUrl(baseUrl: appEnvironmentModel.infoPlist.baseUrl), preview: SharePreview(title))
    }
}
