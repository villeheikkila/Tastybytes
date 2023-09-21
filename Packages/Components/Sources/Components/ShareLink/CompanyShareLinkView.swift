import Models
import SwiftUI

public struct CompanyShareLinkView: View {
    let company: Company

    public init(company: Company) {
        self.company = company
    }

    private var title: String {
        company.name
    }

    public var body: some View {
        ShareLink("Share", item: NavigatablePath.company(id: company.id).url, preview: SharePreview(title))
    }
}
