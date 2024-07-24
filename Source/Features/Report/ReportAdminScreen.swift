import Components
import EnvironmentModels
import Models
import SwiftUI

struct ReportAdminScreen: View {
    @Environment(AdminEnvironmentModel.self) private var adminEnvironmentModel

    var body: some View {
        List(adminEnvironmentModel.reports) { report in
            ReportAdminRowView(report: report)
                .swipeActions {
                    AsyncButton("report.admin.resolve.label", systemImage: "checkmark", action: {
                        await adminEnvironmentModel.resolveReport(report)
                    })
                    AsyncButton(
                        "labels.delete",
                        systemImage: "trash",
                        role: .destructive,
                        action: { await adminEnvironmentModel.deleteReport(report) }
                    )
                }
        }
        .refreshable {
            await adminEnvironmentModel.loadReports()
        }
        .animation(.default, value: adminEnvironmentModel.reports)
        .overlay {
            if adminEnvironmentModel.reports.isEmpty {
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
