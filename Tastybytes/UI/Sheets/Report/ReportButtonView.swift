import Models
import SwiftUI

struct ReportButton: View {
    let entity: Report.Entity

    var body: some View {
        RouterLink("Report", systemSymbol: .exclamationmarkBubbleFill, sheet: .report(entity))
    }
}
