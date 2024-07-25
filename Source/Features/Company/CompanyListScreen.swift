import Models
import SwiftUI

struct CompanyListScreen: View {
    let companies: [Company.Saved]

    var body: some View {
        List(companies) { company in
            RouterLink(open: .screen(.company(company.id))) {
                CompanyEntityView(company: company)
            }
        }
        .listStyle(.plain)
        .verificationBadgeVisibility(.visible)
        .navigationTitle("company.list.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
