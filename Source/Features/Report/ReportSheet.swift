import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ReportSheet: View {
    private let logger = Logger(category: "ReportSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var reasonText = ""

    let entity: Report.Entity

    var body: some View {
        Form {
            Group {
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
            .customListRowBackground()
        }
        .scrollContentBackground(.hidden)
        .navigationTitle(entity.navigationTitle)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    func submitReport() async {
        switch await repository.report.insert(report: Report.NewRequest(message: reasonText, entity: entity)) {
        case .success:
            dismiss()
            router.open(.toast(.success("report.submit.success.toast")))
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Submitting report failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
