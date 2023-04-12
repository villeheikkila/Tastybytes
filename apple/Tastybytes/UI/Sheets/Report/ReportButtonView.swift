import SwiftUI

struct ReportButton: View {
  @EnvironmentObject private var router: Router
  let entity: Report.Entity

  var body: some View {
    RouteLink(sheet: .report(entity), label: {
      Label("Report", systemImage: "exclamationmark.bubble.fill")
    })
  }
}
