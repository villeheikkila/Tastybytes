import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct ReportScreen: View {
    private let logger = Logger(category: "ReportScreen")
    @Environment(Repository.self) private var repository
    @State private var alertError: AlertError?
    @State private var reports = [Report]()

    var body: some View {
        List(reports) { report in
            ReportScreenRow(report: report)
        }
        .scrollContentBackground(.hidden)
        .refreshable {
            await loadInitialData()
        }
        .navigationTitle("report.admin.navigationTitle")
        .alertError($alertError)
        .initialTask {
            await loadInitialData()
        }
    }

    func loadInitialData() async {
        switch await repository.report.getAll() {
        case let .success(reports):
            withAnimation {
                self.reports = reports
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Loading reports failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    public func deleteReport(_ report: Report) async {
        switch await repository.subcategory.delete(id: report.id) {
        case .success:
            withAnimation {
                reports = reports.removing(report)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to delete report \(report.id). Error: \(error) (\(#file):\(#line))")
        }
    }
}

@MainActor
struct ReportScreenRow: View {
    let report: Report

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .center) {
                Avatar(profile: report.createdBy)
                    .avatarSize(.medium)
                Text(report.createdBy.preferredName)
                Spacer()
                Text(report.createdAt.formatted(.customRelativetime))
            }

            if let entity = report.entity {
                entity.view
            }
            if let message = report.message {
                Text(message).font(.callout)
            }
        }
    }
}
