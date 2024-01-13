import EnvironmentModels
import Models
import SwiftUI

public struct CompanyShareLinkView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let company: Company

    public init(company: Company) {
        self.company = company
    }

    private var title: String {
        company.name
    }

    public var body: some View {
        ShareLink("Share", item: NavigatablePath.company(id: company.id).getUrl(baseUrl: appEnvironmentModel.infoPlist.baseUrl), preview: SharePreview(title))
    }
}
