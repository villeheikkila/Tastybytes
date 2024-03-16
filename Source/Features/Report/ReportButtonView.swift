import Models
import SwiftUI

@MainActor
struct ReportButton: View {
    @Environment(Router.self) private var router
    let entity: Report.Entity

    var body: some View {
        Button("report.open", systemImage: "exclamationmark.bubble.fill") {
            router.sheet = .report(entity)
        }
    }
}
