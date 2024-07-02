import Models
import SwiftUI

struct ReportButton: View {
    @Environment(Router.self) private var router
    let entity: Report.Entity

    var body: some View {
        Button("report.open", systemImage: "exclamationmark.bubble.fill") {
            router.openSheet(.report(entity))
        }
    }
}
