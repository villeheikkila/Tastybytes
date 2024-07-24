import Models
import SwiftUI

struct CompanyResultRow: View {
    let company: Company.Saved
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            CompanyEntityView(company: company)
        }
        .listRowBackground(Color.clear)
    }
}

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
