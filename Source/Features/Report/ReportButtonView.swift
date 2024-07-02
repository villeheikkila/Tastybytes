import Models
import SwiftUI

struct ReportButton: View {
    @Environment(Router.self) private var router
    let entity: Report.Entity

    var body: some View {
        RouterLink("report.open", systemImage: "exclamationmark.bubble.fill", sheet: .report(entity))
    }
}
