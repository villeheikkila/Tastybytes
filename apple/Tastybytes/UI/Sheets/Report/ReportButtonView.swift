import SwiftUI

struct ReportButton: View {
  let entity: Report.Entity

  var body: some View {
    RouterLink(sheet: .report(entity), label: {
      Label("Report", systemImage: "exclamationmark.bubble.fill")
    })
  }
}
