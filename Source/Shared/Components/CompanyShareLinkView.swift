import EnvironmentModels
import Models
import SwiftUI

public struct CompanyShareLinkView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let company: Company

    public init(company: Company) {
        self.company = company
    }

    private var link: URL {
        NavigatablePath.company(id: company.id).getUrl(baseUrl: appEnvironmentModel.infoPlist.baseUrl)
    }

    private var title: String {
        company.name
    }

    public var body: some View {
        ShareLink(item: link, subject: Text("company.shareLink.subject"), message: Text(title))
    }
}
