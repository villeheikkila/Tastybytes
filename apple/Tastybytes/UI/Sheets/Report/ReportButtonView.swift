import SwiftUI

struct ReportButton: View {
  @EnvironmentObject private var router: Router
  let entity: Report.Entity

  var body: some View {
    Button(action: { router.navigate(sheet: .report(entity)) }, label: {
      Label("Report", systemImage: "exclamationmark.bubble.fill")
    })
  }
}