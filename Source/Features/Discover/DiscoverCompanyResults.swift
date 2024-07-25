import Models
import SwiftUI

struct DiscoverCompanyResults: View {
    @Environment(Router.self) private var router
    let companies: [Company.Saved]

    var body: some View {
        ForEach(companies) { company in
            CompanyResultRow(company: company, action: {
                router.open(.screen(.company(company.id)))
            })
            .id(company.id)
        }
    }
}
