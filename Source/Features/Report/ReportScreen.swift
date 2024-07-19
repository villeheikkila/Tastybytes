import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ReportScreen: View {
    private let logger = Logger(category: "ReportScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @State private var state: ScreenState = .loading
    @State private var reports = [Report]()
    let filter: ReportFilter?

    var body: some View {
        List(reports) { report in
            ReportScreenRow(report: report, deleteReport: deleteReport, resolveReport: resolveReport)
        }
        .listStyle(.plain)
        .refreshable {
            await loadInitialData()
        }
        .overlay {
            if state != .populated {
                ScreenStateOverlayView(state: state) {
                    await loadInitialData()
                }
            } else if reports.isEmpty {
                ContentUnavailableView("report.admin.isEmpty.title", systemImage: "tray")
            }
        }
        .navigationTitle("report.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .initialTask {
            await loadInitialData()
        }
    }

    private func loadInitialData() async {
        do {
            let reports = try await repository.report.getAll(filter)
            withAnimation {
                self.reports = reports
                state = .populated
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Loading reports failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteReport(_ report: Report) async {
        do {
            try await repository.report.delete(id: report.id)
            withAnimation {
                reports = reports.removing(report)
            }
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete report \(report.id). Error: \(error) (\(#file):\(#line))")
        }
    }

    private func resolveReport(_ report: Report) async {
        do {
            try await repository.report.resolve(id: report.id)
            withAnimation {
                reports = reports.removing(report)
            }
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to resolve report \(report.id). Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct ReportScreenRow: View {
    @Environment(Repository.self) private var repository
    let report: Report

    let deleteReport: (_ report: Report) async -> Void
    let resolveReport: (_ report: Report) async -> Void

    var body: some View {
        RouterLink(open: report.entity.open) {
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
                ReportEntityView(entity: report.entity)
                if let message = report.message {
                    VStack(alignment: .leading) {
                        Text("report.section.report.title").bold()
                        Text(message).font(.callout)
                    }
                }
            }
        }
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
}
