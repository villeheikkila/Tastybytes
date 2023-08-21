import Models
import SwiftUI

struct CompanyShareLinkView: View {
    let company: Company

    private var title: String {
        company.name
    }

    var body: some View {
        ShareLink("Share", item: NavigatablePath.company(id: company.id).url, preview: SharePreview(title))
    }
}
