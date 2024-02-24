import Models
import SwiftUI

@MainActor
struct CompanyResultRow: View {
    let company: Company
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                CompanyLogo(company: company, size: 40)
                VStack(alignment: .center) {
                    Text(company.name)
                        .foregroundStyle(.primary)
                }
            }
        }
        .listRowBackground(Color.clear)
    }
}
