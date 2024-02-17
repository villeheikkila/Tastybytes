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
                reportedEntityView
            }
            Section("report.section.report.title") {
                TextField("report.section.report.reason.label", text: $reasonText, axis: .vertical)
                    .lineLimit(8, reservesSpace: true)
                ProgressButton("label.submit", action: {
                    await submitReport()
                }).bold()
            }
        }
        .navigationTitle(entity.navigationTitle)
        .toolbar {
            toolbarContent
        }
        .alertError($alertError)
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    @ViewBuilder private var reportedEntityView: some View {
        switch entity {
        case let .product(product):
            ProductItemView(product: product, extras: [.companyLink, .logoOnLeft])
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
                Text("report.subBrand \(subBrand.name ?? "Default") from \(brand.name)")
            }
        case let .comment(comment):
            CheckInCommentView(comment: comment)
        case let .checkIn(checkIn):
            CheckInEntityView(checkIn: checkIn, baseUrl: appEnvironmentModel.infoPlist.supabaseUrl)
        }
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

public extension Report.Entity {
    var navigationTitle: LocalizedStringKey {
        switch self {
        case .product:
            "report.navigationTitle.product"
        case .company:
            "report.navigationTitle.company"
        case .brand:
            "report.navigationTitle.brand"
        case .subBrand:
            "report.navigationTitle.subBrand"
        case .checkIn:
            "report.navigationTitle.checkIn"
        case .comment:
            "report.navigationTitle.comment"
        }
    }
}
