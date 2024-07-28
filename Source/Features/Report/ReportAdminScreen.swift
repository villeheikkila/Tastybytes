import Components

import Models
import SwiftUI

struct ReportAdminScreen: View {
    @Environment(AdminModel.self) private var adminModel

    var body: some View {
        List(adminModel.reports) { report in
            ReportAdminRowView(report: report)
                .swipeActions {
                    AsyncButton("report.admin.resolve.label", systemImage: "checkmark", action: {
                        await adminModel.resolveReport(report)
                    })
                    AsyncButton(
                        "labels.delete",
                        systemImage: "trash",
                        role: .destructive,
                        action: { await adminModel.deleteReport(report) }
                    )
                }
        }
        .listStyle(.plain)
        .refreshable {
            await adminModel.loadReports()
        }
        .animation(.default, value: adminModel.reports)
        .overlay {
            if adminModel.reports.isEmpty {
                ContentUnavailableView("report.admin.isEmpty.title", systemImage: "tray")
            }
        }
        .navigationTitle("report.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ReportAdminRowView: View {
    let report: Report.Joined

    var body: some View {
        RouterLink(open: report.open) {
            ReportEntityView(report: report)
        }
    }
}
