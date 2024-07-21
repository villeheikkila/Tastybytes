import Components
import EnvironmentModels
import Models
import SwiftUI

struct ReportAdminScreen: View {
    @Environment(AdminEnvironmentModel.self) private var adminEnvironmentModel

    var body: some View {
        List(adminEnvironmentModel.reports) { report in
            ReportReaderRowView(report: report)
                .swipeActions {
                    AsyncButton("labels.delete", systemImage: "trash") {
                        await adminEnvironmentModel.deleteReport(report)
                    }
                    .tint(.red)
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
