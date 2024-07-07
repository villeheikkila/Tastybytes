import Models
import SwiftUI

struct CompanyListScreen: View {
    let companies: [Company]

    var body: some View {
        List(companies) { company in
            CompanyEntityView(company: company)
        }
        .listStyle(.plain)
        .navigationTitle("company.list.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
