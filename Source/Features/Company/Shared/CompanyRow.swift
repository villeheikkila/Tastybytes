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
    let company: any CompanyProtocol

    var body: some View {
        HStack {
            CompanyLogo(company: company, size: 40)
            VStack(alignment: .center) {
                Text(company.name)
                    .foregroundStyle(.primary)
            }
        }
    }
}
