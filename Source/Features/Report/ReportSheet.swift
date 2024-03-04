import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct ReportSheet: View {
    private let logger = Logger(category: "ReportSheet")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var reasonText = ""
    @State private var alertError: AlertError?

    let entity: Report.Entity

    var body: some View {
        Form {
            Section("report.section.content.title") {
                entity.view
            }
            Section("report.section.report.title") {
                TextField("report.section.report.reason.label", text: $reasonText, axis: .vertical)
                    .lineLimit(8, reservesSpace: true)
                ProgressButton("labels.submit", action: {
                    await submitReport()
                }).bold()
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle(entity.navigationTitle)
        .toolbar {
            toolbarContent
        }
        .alertError($alertError)
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    func submitReport() async {
        switch await repository.report.insert(report: Report.NewRequest(message: reasonText, entity: entity)) {
        case .success:
            dismiss()
            feedbackEnvironmentModel.toggle(.success("report.submit.success.toast"))
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Submitting report failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
