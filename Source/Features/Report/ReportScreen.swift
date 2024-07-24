import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ReportsScreen: View {
    private let logger = Logger(category: "ReportsScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router

    @Binding var reports: [Report.Joined]
    let initialReport: Report.Id?

    var body: some View {
        List(reports) { report in
            ReportScreenRow(report: report)
                .swipeActions {
                    AsyncButton("report.admin.resolve.label", systemImage: "checkmark", action: {
                        await resolveReport(report)
                    })
                    AsyncButton(
                        "labels.delete",
                        systemImage: "trash",
                        role: .destructive,
                        action: { await deleteReport(report) }
                    )
                }
        }
        .listStyle(.plain)
        .animation(.default, value: reports)
        .overlay {
            if reports.isEmpty {
                ContentUnavailableView("report.admin.isEmpty.title", systemImage: "tray")
            }
        }
        .navigationTitle("report.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func deleteReport(_ report: Report.Joined) async {
        do {
            try await repository.report.delete(id: report.id)
            reports = reports.removing(report)
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete report \(report.id). Error: \(error) (\(#file):\(#line))")
        }
    }

    private func resolveReport(_ report: Report.Joined) async {
        do {
            try await repository.report.resolve(id: report.id)
            reports = reports.removing(report)
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to resolve report \(report.id). Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct ReportScreenRow: View {
    let report: Report.Joined

    var body: some View {
        RouterLink(open: report.content.open) {
            ReportEntityView(report: report)
        }
    }
}
