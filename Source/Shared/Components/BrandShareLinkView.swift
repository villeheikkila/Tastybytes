import EnvironmentModels
import Models
import SwiftUI

@MainActor
public struct BrandShareLinkView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let brand: Brand.JoinedSubBrandsProductsCompany

    public init(brand: Brand.JoinedSubBrandsProductsCompany) {
        self.brand = brand
    }

    private var link: URL {
        NavigatablePath.brand(id: brand.id).getUrl(baseUrl: appEnvironmentModel.infoPlist.baseUrl)
    }

    private var title: String {
        "\(brand.brandOwner.name): \(brand.name)"
    }

    public var body: some View {
        ShareLink(item: link, subject: Text("brand.title"), message: Text(title))
    }
}
