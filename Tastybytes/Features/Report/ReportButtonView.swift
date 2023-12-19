import Models
import SwiftUI

struct ReportButton: View {
    let entity: Report.Entity

    var body: some View {
        RouterLink("Report", systemImage: "exclamationmark.bubble.fill", sheet: .report(entity))
    }
}
