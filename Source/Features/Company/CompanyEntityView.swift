import Models
import SwiftUI

struct CompanyEntityView: View {
    let company: any CompanyProtocol

    var body: some View {
        HStack(alignment: .center) {
            CompanyLogo(company: company, size: 40)
            HStack {
                Text(company.name)
                    .foregroundStyle(.primary)
                Spacer()
                VerifiedBadgeView(verifiable: company)
            }
        }
    }
}
