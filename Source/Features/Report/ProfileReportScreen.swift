import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ProfileReportScreen: View {
    let contributionsModel: ContributionsModel

    var reports: [Report] {
        contributionsModel.contributions?.reports ?? []
    }

    var body: some View {
        List(reports) { report in
            ReportReaderRowView(report: report)
                .swipeActions {
                    AsyncButton("labels.delete", systemImage: "trash") {
                        await contributionsModel.deleteReportSuggestion(report)
                    }
                    .tint(.red)
                }
        }
        .animation(.default, value: reports)
        .overlay {
            if reports.isEmpty {
                ContentUnavailableView("report.admin.isEmpty.title", systemImage: "tray")
            }
        }
        .navigationTitle("report.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ReportReaderRowView: View {
    let report: Report

    var body: some View {
        Section {
            ReportEntityView(entity: report.entity)
        } header: {
            if let message = report.message {
                Text(message)
            }
        } footer: {
            Text(report.createdAt.formatted(.customRelativetime))
        }
    }
}
