
import Models
import SwiftUI

public struct BrandShareLinkView: View {
    @Environment(AppModel.self) private var appModel
    let brand: Brand.JoinedSubBrandsCompany

    public init(brand: Brand.JoinedSubBrandsCompany) {
        self.brand = brand
    }

    private var link: URL {
        NavigatablePath.brand(id: brand.id).getUrl(baseUrl: appModel.infoPlist.baseUrl)
    }

    private var title: String {
        "\(brand.brandOwner.name): \(brand.name)"
    }

    public var body: some View {
        ShareLink(item: link, subject: Text("brand.title"), message: Text(title))
    }
}
