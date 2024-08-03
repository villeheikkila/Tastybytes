import Components

import Models
import SwiftUI

struct ReportView: View {
    let report: Report.Joined

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center) {
                AvatarView(profile: report.createdBy)
                    .avatarSize(.medium)
                Text(report.createdBy.preferredName)
                    .font(.caption).bold()
                    .foregroundColor(.primary)
                Spacer()
                Text(report.createdAt.formatted(.customRelativetime))
                    .font(.caption)
            }
            ReportContentView(content: report.content)
            if let message = report.message {
                VStack(alignment: .leading) {
                    Text("report.section.report.title").bold()
                    Text(message).font(.callout)
                }
            }
        }
    }
}
