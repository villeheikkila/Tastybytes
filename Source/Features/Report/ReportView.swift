import Components
import Models
import SwiftUI

struct ReportView: View {
    let report: Report.Joined

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            CreationInfoHeaderView(createdBy: report.createdBy, createdAt: report.createdAt)
            ReportContentView(content: report.content)
                .padding()
                .background(.gray.opacity(0.1), in: .rect(cornerRadius: 16))
                .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 2)
            if let message = report.message {
                VStack(alignment: .leading) {
                    Text("report.section.report.title").bold()
                    Text(message).font(.callout)
                }
            }
        }
    }
}
