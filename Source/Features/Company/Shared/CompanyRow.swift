import Models
import SwiftUI

struct CompanyResultRow: View {
    let company: Company.Saved
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            CompanyView(company: company)
        }
        .listRowBackground(Color.clear)
    }
}
