
import Models
import SwiftUI

struct ReportButton: View {
    let entity: Report.Content

    var body: some View {
        RouterLink("report.open", systemImage: "exclamationmark.bubble.fill", open: .sheet(.report(entity)))
    }
}
