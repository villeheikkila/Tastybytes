import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ReportSheet: View {
    private let logger = Logger(category: "ReportSheet")
    @Environment(\.repository) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var reasonText = ""
    @State private var alertError: AlertError?

    let entity: Report.Entity

    var body: some View {
        Form {
            Section {
                reportedEntityView
            } header: {
                Text("Content in question")
            }
            Section("Report") {
                TextField("Reason", text: $reasonText, axis: .vertical)
                    .lineLimit(8, reservesSpace: true)
                ProgressButton("Submit", action: {
                    await submitReport()
                }).bold()
            }
        }
        .navigationTitle("Report \(entity.label)")
        .toolbar {
            toolbarContent
        }
        .alertError($alertError)
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button("Cancel", role: .cancel, action: { dismiss() }).bold()
        }
    }

    @ViewBuilder private var reportedEntityView: some View {
        switch entity {
        case let .product(product):
            ProductItemView(product: product, extras: [.companyLink, .logo])
        case let .company(company):
            HStack {
                Text(company.name)
            }
        case let .brand(brand):
            HStack {
                Text(brand.name)
            }
        case let .subBrand(brand, subBrand):
            HStack {
                Text("\(subBrand.name ?? "Default") sub-brand from \(brand.name)")
            }
        case let .comment(comment):
            CheckInCommentView(comment: comment)
        case let .checkIn(checkIn):
            CheckInEntityView(checkIn: checkIn)
        }
    }

    func submitReport() async {
        switch await repository.report.insert(report: Report.NewRequest(message: reasonText, entity: entity)) {
        case .success:
            await MainActor.run {
                dismiss()
            }
            feedbackEnvironmentModel.toggle(.success("Report submitted!"))
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Submitting report failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
