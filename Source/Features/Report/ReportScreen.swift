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
}

struct ReportScreenRow: View {
    let report: Report

    var body: some View {
        Text(report.message)
    }
}
