import Models
import SwiftUI

struct ReportButton: View {
    @Binding var sheet: Sheet?
    let entity: Report.Entity

    var body: some View {
        Button("Report", systemImage: "exclamationmark.bubble.fill") {
          sheet =  .report(entity)
        }
    }
}
