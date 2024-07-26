import Components

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

    let reportContent: Report.Content

    var body: some View {
        Form {
            content
        }
        .scrollContentBackground(.hidden)
        .navigationTitle(reportContent.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ViewBuilder private var content: some View {
        Group {
            Section("report.section.content.title") {
                ReportContentEntityView(content: reportContent)
            }
            Section("report.section.report.title") {
                TextField("report.section.report.reason.label", text: $reasonText, axis: .vertical)
                    .lineLimit(8, reservesSpace: true)
            }
        }
        .customListRowBackground()
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItem(placement: .primaryAction) {
            AsyncButton("labels.submit", action: {
                await submitReport()
            })
            .bold()
        }
    }

    private func submitReport() async {
        do {
            try await repository.report.insert(report: Report.NewRequest(message: reasonText, entity: reportContent))
            dismiss()
            router.open(.toast(.success("report.submit.success.toast")))
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Submitting report failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
