import Components
import EnvironmentModels
import Models
import SwiftUI

struct ReportEntityView: View {
    let report: Report

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center) {
                Avatar(profile: report.createdBy)
                    .avatarSize(.medium)
                Text(report.createdBy.preferredName)
                    .font(.caption).bold()
                    .foregroundColor(.primary)
                Spacer()
                Text(report.createdAt.formatted(.customRelativetime))
                    .font(.caption)
            }
            ReportContentEntityView(content: report.content)
            if let message = report.message {
                VStack(alignment: .leading) {
                    Text("report.section.report.title").bold()
                    Text(message).font(.callout)
                }
            }
        }
    }
}
