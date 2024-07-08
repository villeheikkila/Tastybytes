import Models
import SwiftUI

struct CompanyResultRow: View {
    let company: Company
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            CompanyEntityView(company: company)
        }
        .listRowBackground(Color.clear)
    }
}

struct CompanyEntityView: View {
    @Environment(\.verificationBadgeVisibility) private var verificationBadgeVisibility
    let company: any CompanyProtocol

    var body: some View {
        HStack(alignment: .center) {
            CompanyLogo(company: company, size: 40)
            Text(company.name)
                .foregroundStyle(.primary)
            if verificationBadgeVisibility == .visible, company.isVerified {
                VerifiedBadgeView()
            }
        }
    }
}
