
import Models
import SwiftUI

struct CompanyShareLinkView: View {
    @Environment(AppModel.self) private var appModel
    let company: any CompanyProtocol

    private var link: URL {
        NavigatablePath.company(id: company.id).getUrl(baseUrl: appModel.infoPlist.baseUrl)
    }

    private var title: String {
        company.name
    }

    public var body: some View {
        ShareLink(item: link, subject: Text("company.shareLink.subject"), message: Text(title))
    }
}
